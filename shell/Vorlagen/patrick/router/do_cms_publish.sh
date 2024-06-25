#!/bin/bash

#set -x

LOG="logger -s -t CMS_PUBLISH"
#exec 1> >($LOG) 2>&1

S3="aws s3 --output=text"
TAR="tar"
LN="ln -s"
RMLINK="rm -f"
RMDIR="rm -rf"
CHOWNWWW="chown -R www-data:www-data"

# LOCAL CONFIGURATION
s3_bucket=$S3_BUCKET
s3_dir=$S3_DIR
s3_region="eu-west-1"
cache_dir="/tmp"
deploy_dir="/var/www"
current_www_link="$deploy_dir/current"
previous_www_link="$deploy_dir/previous"

function retval {
        $@ 1> /dev/null 2>&1
        local status=$?
        echo $status
}

function head_of_list {
        local hd=$(echo "$1" | awk -F' ' '{print $1}')
        echo $hd
}

function version_from_archive {
        local filename="$1"
        echo "$filename" | awk -F'.' '{printf "%d", $1}'
}

function remove_double_slashes {
        local path="$1"
        echo $path | awk '{ gsub(/(\/+)/, "/"); sub(/^s3:\//, "s3://");  print; }'
}

function validate_parameters {
        local error=0

        if [[ -z "$s3_bucket" ]]; then
                $LOG "S3_BUCKET argument not supplied"
                error=1
        fi

        if [[ $error == 0 ]] &&  [[ "$(retval "$S3 ls $s3_bucket")" != 0 ]]; then
                $LOG "S3 bucket '$s3_bucket' either does not exist or is not accessible"
                error=1
        fi

        if [[ ! -d $cache_dir ]]; then
                $LOG "Cache dir $cache_dir does not exist"
                error=1
        fi

        return $error
}

function try_take_lock {
        local lock_file=$(remove_double_slashes "$cache_dir/cms_publish.lock")

        if [[ -f $lock_file ]]; then
                return 1
        fi

        touch $lock_file
        return 0
}

function release_lock {
        local lock_file=$(remove_double_slashes "$cache_dir/cms_publish.lock")
        $RMLINK "$lock_file"
}

function get_ordered_s3_file_list {
        local file_list=$($S3 ls $s3_bucket/$s3_dir | awk -F' ' '{print $4}' | sort -rn)
        echo $file_list
}

function get_ordered_local_dir_list {
        local dir_list=$(find "$deploy_dir/*" -maxdepth 0 -type d 2>/dev/null)
        if [[ ! -z $dir_list ]]; then
                dir_list=$(basename -a "$dir_list" | sort -rn)
                echo $dir_list
        fi
}

function is_remote_version_greater {
        local s3_version=$(head_of_list "$1")
        s3_version=$(version_from_archive "$s3_version")
        #local local_version=$(head_of_list "$2")
        local local_version=
        if [[ -L $current_www_link ]]; then
                local_version=$(basename $(readlink "$current_www_link"))
        fi

        $LOG "Found remote version '$s3_version' and local version '$local_version'"

        if [[ $s3_version -lt 1 ]]; then
                $LOG "Unable to get extract a remote version"
                return 1
        fi

        if [[ $s3_version -gt $local_version ]]; then
                return 0
        else
                return 1
        fi
}

function fetch_latest_file {
        local s3_file=$(head_of_list "$1")
        local s3_path="$s3_bucket/$s3_dir/$s3_file"
        s3_path=$(remove_double_slashes "$s3_path")

        local download_path="$cache_dir/$s3_file"
        download_path=$(remove_double_slashes "$download_path")

        $S3 --region="$s3_region" cp "$s3_path" "$download_path" 1> /dev/null
        if [[ $? -ne 0 ]]; then
                $LOG "Failure during download S3 path '$s3_path'"
                return 1
        fi

        local file_size=$(numfmt --to=iec-i --suffix=B --format="%3f" $(stat -c "%s" "$download_path"))

        $LOG "Finished downloading $file_size archive to '$download_path'"
        echo $download_path
        return 0
}

function extract_file_to_deploy_dir {
        local downloaded_file="$1"
        local version=$(version_from_archive "$(basename $downloaded_file)")
        local new_version_deploy_dir=$(remove_double_slashes "$deploy_dir/$version")

        if [[ -d $new_version_deploy_dir ]]; then
                $LOG "Deployment dir for new version '$new_version_deploy_dir' already exists, removing it"
                $RMDIR "$new_version_deploy_dir"
        fi

        if [[ ! -d $new_version_deploy_dir ]]; then
                mkdir -p -m 755 $new_version_deploy_dir
        fi

        if [[ ! -d $new_version_deploy_dir ]]; then
                $LOG "Deployment dir for new version '$new_version_deploy_dir' not accessible"
                return 1
        fi

        $TAR -xv -f $downloaded_file  -C $new_version_deploy_dir &> /dev/null
        if [[ $? -ne 0 ]]; then
                $LOG "Failure during extraction of archive to '$new_version_deploy_dir'"
                return 1
        fi
        $CHOWNWWW "$new_version_deploy_dir"
        $RMLINK "$downloaded_file"

        echo $new_version_deploy_dir
        return 0
}

function roll_versions_in_deploy_dir {
        local new_version_deploy_dir="$1"
        local new_prev_target=""
        local new_cur_target=""
        local target_to_delete=""

        if [[ -f $current_www_link ]] && [[ ! -h $current_www_link ]]; then
                $LOG "Current www '$current_www_link' exists, but is not a symlink, this should not happen"
                return 1
        fi

        if [[ -f $previous_www_link ]] && [[ ! -h $previous_www_link ]]; then
                $LOG "Previous www '$previous_www_link' exists, but is not a symlink, this should not happen"
                return 1
        fi

        if [[ -L $current_www_link ]]; then
                new_prev_target=$(readlink "$current_www_link")
                if [[ -L $previous_www_link ]]; then
                        target_to_delete=$(readlink "$previous_www_link")
                fi
        fi

        $RMLINK "$current_www_link"
        $LN "$new_version_deploy_dir" "$current_www_link"
        $CHOWNWWW "$current_www_link"
        if [[ $? -ne 0 ]]; then
                $LOG "Error while linking new version dir '$new_version_deploy_dir' to '$current_www_link', not good!"
                return 1
        fi

        if [[ ! -z $new_prev_target ]]; then
                $RMLINK "$previous_www_link"
                $LN "$new_prev_target" "$previous_www_link"
                $CHOWNWWW "$previous_www_link"
        fi

        if [[ ! -z $target_to_delete ]]; then
                $RMDIR $target_to_delete
        fi

        return 0
}

function main {

        if ! try_take_lock; then
                $LOG "Another CMS Publishing process is currently running, exiting"
                exit 1
        fi

        if ! validate_parameters; then
                $LOG "Parameter validation failed, exiting"
                release_lock
                exit 1
        fi

        s3_file_list=$(get_ordered_s3_file_list)
        local_dir_list=$(get_ordered_local_dir_list)

        if ! is_remote_version_greater "$s3_file_list" "$local_dir_list"; then
                $LOG "Local version already up to date, exiting"
                release_lock
                exit 0
        fi

        downloaded_file=$(fetch_latest_file "$s3_file_list")
        if [[ $? -ne 0 ]]; then
                $LOG "Download of latest remote version failed, exiting"
                release_lock
                exit 1
        fi

        new_version_deploy_dir=$(extract_file_to_deploy_dir "$downloaded_file")
        if [[ $? -ne 0 ]]; then
                $LOG "Extraction to deployment dir failed, exiting"
                release_lock
                exit 1
        fi

        roll_versions_in_deploy_dir "$new_version_deploy_dir"
        if [[ $? -ne 0 ]]; then
                $LOG "Rolling of versions in deployment dir failed, exiting"
                release_lock
                exit 1
        fi

        $LOG "Success! Finished deployment of '$downloaded_file'"
        release_lock
}

main