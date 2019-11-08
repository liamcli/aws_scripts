"""
Utils for working with AWS.
"""
import boto3
import os


def delete_all_from_s3(directory, bucket):
    """Deletes everything from the corresponding directory on S3."""
    prefix = directory[1:] if directory[0] == "/" else directory
    # TODO: switch the prefix to above once we're okay deleting old
    # checkpoints.
    s3 = boto3.resource("s3")
    s3.Bucket(bucket).objects.filter(Prefix=directory).delete()


def upload_file_to_s3(source, bucket, key):
    """Uploads a source file to the S3 bucket."""
    if key[0] == "/":
        key = key[1:]
    s3 = boto3.resource("s3")
    s3.meta.client.upload_file(source, bucket, key)


def upload_all_to_s3(directory, bucket):
    """Uploads a directory to the S3 bucket."""
    for file_path in get_file_paths(directory):
        upload_file_to_s3(file_path, bucket, file_path)


def get_file_paths(directory):
    """Returns file paths relative to the provided directory."""
    file_paths = []
    for root, dirs, files in os.walk(directory):
        for fname in files:
            file_paths.append(os.path.join(root, fname))
    return file_paths


def download_from_s3(key, bucket, target):
    """Downloads a file from S3 bucket to the target directory."""
    # Make sure directory exists before downloading to it.
    target_dir = os.path.dirname(target)
    os.makedirs(target_dir, exist_ok=True)

    s3 = boto3.resource("s3")
    s3.meta.client.download_file(bucket, key, target)


def download_prefix_from_s3(prefix, bucket, filetype=None, local="/tmp"):
    """
    Download files with the given prefix from bucket to local directy while optionally filtering by
    filetype.
    prefix: folder name or leave empty for root directory of bucket.
    """
    s3_client = boto3.client("s3")
    s3_resource = boto3.resource("s3")

    keys = []
    dirs = []
    next_token = ""

    base_kwargs = {"Bucket": bucket}
    if prefix is not None:
        base_kwargs["Prefix"] = prefix[1:] if prefix[0] == "/" else prefix

    while next_token is not None:
        kwargs = base_kwargs.copy()
        if next_token != "":
            kwargs.update({"ContinuationToken": next_token})
        results = s3_client.list_objects_v2(**kwargs)
        contents = results.get("Contents")
        for i in contents:
            k = i.get("Key")
            if filetype is None or k[-len(filetype) :] == filetype:
                keys.append(k)
            elif k[-1] == "/":
                dirs.append(k)
        next_token = results.get("NextContinuationToken")
    for d in dirs:
        dest_pathname = os.path.join(local, d)
        if not os.path.exists(os.path.dirname(dest_pathname)):
            os.makedirs(os.path.dirname(dest_pathname))
    for k in keys:
        dest_pathname = os.path.join(local, k)
        if not os.path.exists(os.path.dirname(dest_pathname)):
            os.makedirs(os.path.dirname(dest_pathname))
        s3_resource.meta.client.download_file(bucket, k, dest_pathname)

