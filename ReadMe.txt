** This is reading for creating an App Extension to enable importing stuff from other apps into this one**

Apple's App Extension Programming Guide
https://developer.apple.com/library/prerelease/ios/documentation/General/Conceptual/ExtensibilityPG/index.html#//apple_ref/doc/uid/TP40014214-CH20-SW1

So far, I've:
1) enabled App Groups
2) Added a Readme file to the project

Steve says use this:

UIDocumentPicker
http://www.macstories.net/tutorials/implementing-ios-8-document-pickers/

Steps after enabling iCloud
1) Add the iCloud entitlement to your Apple ID
2) Add the iCloud containers to your Apple ID
3) Add the iCloud entitlement to your entitlements file
4) Link CloudKit framework

Replace textField w/ textView in AddNoteVC

Search bar info
http://useyourloaf.com/blog/2015/02/16/updating-to-the-ios-8-search-controller.html?utm_campaign=iOS_Dev_Weekly_Issue_186&utm_medium=email&utm_source=iOS%252BDev%252BWeekly