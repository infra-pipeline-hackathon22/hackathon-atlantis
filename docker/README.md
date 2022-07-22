# Building the image

1. Log into the ghcr per [these instructions](infra-pipeline-hackathon22/python-atlantis:v0.0.1)
2. Go to the `docker` subdirectory
3. Run the following:
```
IMAGE="ghcr.io/infra-pipeline-hackathon22/python-atlantis"
TAG="v0.0.3"
DOCKER_BUILDKIT=1 docker build -f Dockerfile -t ${IMAGE}:${TAG} . 
```
4. Push image
```
docker push ${IMAGE}:${TAG}
```