# Introduction { #introduction }

As a vibrant research group, the members of NiL have produced and produce a
great number of computational tools and systems. Traditionally, systems
developed in a scientific environment are meant to be shared, often in the form
of reusable code or libraries. Recently, the trend is to provide access to these
implementations via the internet, offloading the burdens of installation and
memory and computing requirements from the users. In our group, many such "web
services" have been and are being produced.

In order to increase the usability of this service ecosystem, a unifying point
has been developed. This "gateway" has a number of advantages, both for external
users and for the group itself. Users benefit of a unified access convention, a
well-organized and documented API which they can consume in a predictable and
usable way. To the members of the group, the gateway provides industry-strength
solutions to common but hard problems such as security, caching, load-balancing,
and others, without the need to encumber the researchers with the implementation
of such unrelated tasks.

Finally, the gateway also allows us to gather our legacy services, which have
been developed before the standardization, and give a more usable and
predictable interface to them without having to rewrite any of the code. Our
unified API, based on common practice nowadays, can give access using JSON and
HTTP verbs to various services which may originally consume XML, raw text, or
use any haphazard path scheme.

In this document, we describe the main aspects of our implementation of the
gateway. Section \ref{background} describes some of the technologies used,
and section \ref{architecture} then details the architecture of the system
and how these technologies combine to form the gateway.
