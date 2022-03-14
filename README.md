# Workshop - Application Pool

What if you have a legacy application that you want to run in Google Cloud,
and you still want to take advantage of as much of the automation and intelligent
application management as possible?

What if your application _also_ has some pretty heinous constraints such as:

- It can't be containerized for legal/policy reasons
- It requires about a day turnaround time to provision license entitlements for each instance created

This is the problem we'll work to solve in this workshop.

**Note**: If you arrived at this repo from a random search please STOP reading
now. Unless you are working with the very specific constraints listed above, I
strongly recommend that you instead use tools such as
[Kubernetes](https://cloud.google.com/kubernetes-engine) to manage modern
applications on Google Cloud.

**Note**: This repo contains snippets we'll used to learn and experiment and
work to solve a very specific problem. Nothing here is production-ready and
should not be used for any production applications.

**Note**: This is WIP and isn't completely working yet.

## Test scenarios

- [Basic Application Pool](workshop-application-pool.md)
