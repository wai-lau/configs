###
# Install Commands
###

mr.install_buildifier() {
  (
    echo "Installing buildifier..."
    cd $MONOREPO_PATH
    bazel run --script_path=/usr/local/bin/buildifier //:buildifier
    echo "buildifier installed to /usr/local/bin/buildifier"
  )
}

# ash
ash_deploy_project() {
  # this requires `brew install awscli` to have been run before
  ash deploy -p $@
}

ash_assume() {
  assume-role core-codeflow-prod-use1 eng-ops
}

ash_login() {
  assume-role core-codeflow-prod-use1 eng-ops
}

unalias ash 2>/dev/null

# Install remote-dev alias: rbazel
eval "$(mr.remote rbzl-cmd 2>/dev/null)"

assume-sudo() {
  local environment="$1"
  assume-role -mfa $environment sudo
}

ecr_login() {
  aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
}

mr.retry_build() {
  (
      set -e
      cd $MONOREPO_PATH
      COMMIT=${1:-$(git rev-parse HEAD)}
      BUILDER=${2:-"master"}
      MESSAGE=$(git show -s --format=%B $COMMIT)
      echo -n "Retry $COMMIT '$MESSAGE' (y/n)?"
      read answer
      if [ "$answer" != "y" ] ; then
          echo "canceling not 'y'"
          return
      fi
      echo "Assuming eng-ops"
      assume-role core-codeflow-prod-use1 eng-ops
      echo "Rebuilding commit: $COMMIT with builder: $BUILDER"
      bazel run infra/clients/artifact-builder/rebuilder -- --commit=$COMMIT --builder=$BUILDER
  )
}

mr.install-remote-dev() {
    $MONOREPO_PATH/scripts/rc/mr_remote.install.sh
}

mr.info() {
    open "http://go/mr-info"
}
