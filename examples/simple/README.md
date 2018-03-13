# Simple Example

This simple example demonstrates using the cached AWS AMI data source to resolve 2 AMI IDs.

If you apply the TF configuration, you should see the default behavior where searching for
and resolving the AMIs takes a bit of time.

After you apply the TF configuration on subsequent invocations, you should find that the
resolving the AMIs is almost immediate as long as you perform them within the default
cache period (12 hours).  You can adjust the cache period on a per module instance.
