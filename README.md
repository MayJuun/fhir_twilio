# A simple setup to read FHIR CommunicationRequests and send an SMS via Twilio

### Note, all of the Twilio library is stolen directly from [twilio_flutter](https://github.com/adarshbalu/twilio_flutter), with a big thanks to [Adarsh Balachandran](https://github.com/adarshbalu) who maintains it. The pub.dev package is still certified for Flutter, although it worked perfectly well on just the Dart SDK. I will remove that directory and just include it as a dependency if the package gets updated and no longer require the Flutter SDK.  


## You will need to create a twilio.yaml file, and place it in the ```lib``` directory, it should look like this:
```
## Account Sid of your Twilio Account
accountSid: 'alphaNumbericString'
## AuthToken from your Twilio Account
authToken: 'alphaNumbericString'
## Twilio Phone Number
twilioNumber: '+12345678901'
## The number you would like to try and test to
sendNumber: '+12345678901'

## The following values can be integers or "*"
## It uses this package: https://pub.dev/packages/cron
## Here is a nice tutorial: https://medium.com/flutterworld/flutter-run-function-repeatedly-using-cron-4aa030eda332
## The 5 together make up a cron string "0 * * * * *" this default value runs every hour
minute: '0'
hour: '*'
day: '*'
month: '*'
dayOfWeek: '*'

baseUrl: 'http://hapi.fhir.org/baseR4/'
```
## Create new CommuncationRequest
1. Go to Hapi's [Public Endpoint for CommunicationRequests](http://hapi.fhir.org/resource?serverId=home_r4&pretty=false&_summary=&resource=CommunicationRequest)
2. Click on the CRUD Operations Tab
3. Under Create, Place the following resource text with your editable "contentString" in place of "New Content!"
```
{
      "resourceType": "CommunicationRequest",
      "status": "active",
      "payload": [
                {
                    "contentString": "New Content!"
                 }
      ]
}
```
4. Click the Create Button

## To build your Docker Container
Quick shout outs to the following people for making my life much easier for this:
- Jermaine Oppong YouTube Tutorial
- Nick Manning YouTube Tutorial
- Tony Pujals - Google Engineer

The reason I have a file called ```server.dart``` in a ```bin``` directory is because I've stolen this docker file from my repo about [servers](https://github.com/MayJuun/servers), and this way the setup is the same (except in this case I'm copying the entire lib directory instead of just a file...although I should probably do that for the servers too) For right now it's probably just easy to leave all of the files where they are.

### Docker - let's build!
1. Ensure docker is installed, to check run:
```$ docker run hello-world```

2. Go to the root directory of this project and run
```$ docker build -t projectName .```

3. Test it:
```$ docker run projectName```

## Google Cloud 
(I haven't actually tested this workflow on this Repo, but it's the same as for the server package above)
1. Get Google Cloud account
2. Create Project
3. Note Project ID
4. Enable Container Registry & Cloud Run APIs
5. Initialize gcloud
```$ gcloud init```
6. Configure docker for gcloud
```$ gcloud auth configure-docker```
7. Build container in Google Cloud Container Registry
```$ docker build -t gcr.io/projectId/projectName:version .```
8. For the above, the projectId is your GCP project ID, the projectName is the name of the docker file that we had above, and the version is however you want to define versions in the cloud so in the future you'll know which is which. For instance, if our GCP project Id is ```new-project-123456``` our docker project was called docker-project, we would write:
```$ docker build -t gcr.io/new-project-123456/docker-project:v0.1 .```
9. Push container to cloud
```$ docker push gcr.io/projectId/projectNam:version```
10. If you go to your GCP console and open the Container Registry, you should see the container that you just pushed
11. Open Cloud Run in your GCP Console
12. Create Service, choose your service name, and pick your Region
13. Select ```Deploy one revision from an existing container image```, and choose the image you just uploaded
14. Click on Advanced Settings, and under Capacity, change the Memory allocated to ```1 GiB```
15. ~~For testing purposes~~
~~- Ingress: Allow all traffic~~
~~- Authentication: Allow unauthenticated invocations~~ I'll need to update this when I get around to it.
16. Create!