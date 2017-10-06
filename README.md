# Internet-Draft-Template Repo

This is an example repo for internet-drafts.  It assumes a single file named "draft<whatever>.xml".  If you want to use this for your draft, fork/copy the repo, remove *.xml and *.yang and drop in your own draft<XXX>.xml, and .yang files if you have them.  Take a look at the Makefile to see available targets.

Caution: if you are using YANG, the makefile will automatically update the xml based on yang module file changes, but you MUST use the following format for noting the yang in your xml file:
```
    <CODE BEGIN> file MODULE_NAME@DATE,yang
```
and
```
    <CODE ENDS>
```
where MODULE_NAME matches a file named MODULE_NAME.yang

If you configure travis, it will automatically run 'make targets' and provie reslts as shown below.  

## Current xml2rfc and idnits results: ![alt text](https://api.travis-ci.org/louberger/ttesting.svg?branch=master)
* For details see: https://travis-ci.org/louberger/ttesting
* For results on past commits see: https://travis-ci.org/louberger/ttesting/builds

## Fomatted versions: [text](https://xml2rfc.tools.ietf.org/cgi-bin/xml2rfc.cgi?url=https://raw.githubusercontent.com/louberger/ttesting/master/draft-acee-netmod-rfc8022bis.xml) or  [html](https://xml2rfc.tools.ietf.org/cgi-bin/xml2rfc.cgi?url=https://raw.githubusercontent.com/louberger/ttesting/master/draft-acee-netmod-rfc8022bis.xml&modeAsFormat=html%2Fascii)

## idnits: [results](https://tools.ietf.org/idnits?url=https://xml2rfc.tools.ietf.org/cgi-bin/xml2rfc.cgi?url=https://raw.githubusercontent.com/louberger/ttesting/master/draft-acee-netmod-rfc8022bis.xml&modeAsFormat=html%2Fascii)
