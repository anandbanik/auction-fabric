export DEBIAN_FRONTEND=noninteractive

# ----------------------------------------------------------------
# Update the entire system to the latest versions
# ----------------------------------------------------------------
apt-get clean && apt-get -qq update && apt-get upgrade -y

# ----------------------------------------------------------------
# Install java and maven
# ----------------------------------------------------------------
apt-get install -y openjdk-11-jdk
apt-get install -y maven