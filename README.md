#Artifactory Bosh Release
## To setup your workstation:
To start this project from 0:  
###Prerequisites
Ruby  (pre-loaded on mac).  Suggest you configure it to point to your artifactory server, if you have one.  
###Setting up ruby and bosh
Depending on your configuration, the following command may require sudo:
```
gem install bundler
```
Clone this repository: If desired, modify the sources line in Gemfile to point at an Artifactory  
Now to install the necessary gems, from the root of this git:
```
bundle install
```
then determine the appropriate bosh used for development and run
```
bosh target <insert bosh location here>
```
