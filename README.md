# Overview

**Title:** Birdie Orange  
**Category:** Web  
**Flag:** `libctf{05c86f2a-87de-4ace-904b-16ef5d2fa5cf}`  
**Difficulty:** Trivial

# Usage

The following will pull the latest 'elttam/ctf-birdie-orange' image from DockerHub, run a new container named 'libctfso-birdie-orange', and publish the vulnerable service on port 80:

```sh
docker run --rm \
  --publish 80:80 \
  --name libctfso-birdie-orange \
  elttam/ctf-birdie-orange:latest
```

# Build (Optional)

If you prefer to build the 'elttam/ctf-birdie-orange' image yourself you can do so first with:

```sh
docker build ${PWD} \
  --tag elttam/ctf-birdie-orange:latest
```
