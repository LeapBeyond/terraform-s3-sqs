# Bootstrap
This is where scripts and other materials needed to initially bootstrap up before running Terraform

It is assumed that:
 - the AWS CLI is available
 - appropriate AWS credentials are available
 - the scripts are being run on a unix account.

## Sets up
 - initial key pairs.

## To use
Copy the `env.rc.template` to `env.rc` and fill in the blanks. Be careful not to commit the actual `env.rc` to git!

Assuming that you have your profile setup correctly in `.aws` and that profile has appropriate (very broad) privileges,
then just execute the `bootstrap.sh` script then jump into the console to verify it contains what you expect. Additionally some `.pem` files
should be written into the `data` folder.
