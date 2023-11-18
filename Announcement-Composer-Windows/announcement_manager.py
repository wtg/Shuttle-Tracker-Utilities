from cryptography.hazmat.primitives.asymmetric import ed25519
import requests
import json
import argparse

userRequests = None
serverChoice = input("Do you want to get the announcement from the staging or production server? [s/p] ")
while (True):
    if (serverChoice.lower() in ["staging", "s"]):
        userRequests = requests.get("https://staging.shuttletracker.app/announcements")
        userRequests = json.loads(userRequests.content.decode('utf-8'))
        break
    elif (serverChoice.lower() in ["production", "p"]):  
        userRequests = requests.get("https://shuttletracker.app/announcements")
        userRequests = json.loads(userRequests.content.decode('utf-8'))

        break
    else:
        print("Please type in a valid command. [s/p] ")
     
            

def displayAllAnnouncements(requestList):
    counter = 1
    print("Announcements:")
    for r in requestList:
        uuid, subject, start = r["id"],  r["subject"], r["start"]
        print(f"[{counter}] {subject}: {uuid}")
        counter+=1
    return

def viewDetails(requestList, announceNum):
    counter = 1
    requestObj = dict()
    for r in requestList:
        if (counter == announceNum):
            requestObj = r
            break
        counter+=1
    uuid, subject, body, scheduleType = requestObj["id"],  requestObj["subject"], requestObj["body"], requestObj["scheduleType"]
    start, end, interruptionLevel, signature = requestObj["start"], requestObj["end"], requestObj["interruptionLevel"], requestObj["signature"]
    print("Announcement #{announceNum}:")
    print("--- UUID: {uuid}")
    print("--- Subject: {subject}")
    print("--- Body: {body}")
    print("--- Schedule Type: {scheduleType}")
    print("--- Start Date: {start}")
    print("--- End Date: {end}")
    print("--- Interruption Level: {interruptionLevel}")
    print("--- Signature: {signature}")
    return

def deleteAnnouncement(requestDict, announceNum):
    return


userCommand = ""
while (True):
    userCommand = input("What action would the user like to do? [v/d] ")
    displayAllAnnouncements(userRequests)
    if (userCommand.lower() == "v"):
        num = int(input("Which announcement would you like to view? "))
        viewDetails(userRequests, num)
    elif (userCommand.lower() == "d"):
        num = int(input("Which announcement would you like to delete? "))
        deleteAnnouncement(userRequests, num)
    elif (userCommand.lower() in ["quit", "exit"]):
        break

