# Programming Keyboard for iPad
Deceptively Simple, Vastly Powerful.

[![Build Status](https://travis-ci.org/junlong-gao/Programming_Keyboard.svg?branch=master)](https://travis-ci.org/junlong-gao/Programming_Keyboard)
[![Issue Count](https://codeclimate.com/github/junlong-gao/Programming_Keyboard/badges/issue_count.svg)](https://codeclimate.com/github/junlong-gao/Programming_Keyboard)
## An EECS481 Project by Finger Wizards
#Demos:
![DEMO](demos/context_aware_assistence.gif?raw=true "Title=Context Aware Assistance")
![DEMO](demos/prefix.gif?raw=true "Title=prefix completion")

#Team:
* (Slack) https://eecs481team.slack.com/messages/general/
* (Agile Jira Board) https://fingerwizards.atlassian.net/secure/RapidBoard.jspa?projectKey=PKII&rapidView=1&view=planning.nodetail

#Build
1. Use Xcode Version 8.1 beta (8T47) on Mac OS 10.12
2. Build and tested on iPad Air 2
3. Run "pod install" in the root repo.

#Notes and Known Issues
1. The completion starts when last input stroke is a whitespace or newline.
2. The completion stops when rewind cursor backwards.
3. Now the completion only consists of a predefined set of C++ keyword. 
4. Uses a google drive (not umich google drive) account for sketch board sync.
5. The Schema file is supposed to be of the form "_Schema_[name].txt" where name now support "cpp", "java".
