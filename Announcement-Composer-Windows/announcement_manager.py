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
        countStr = str(counter)
        if (counter < 10):
            countStr="0"+str(counter)
        print(f"[{countStr}] {subject}: {uuid}")
        counter+=1
    print()
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
    print(f"\nAnnouncement #{announceNum}:")
    print(f"--- UUID: {uuid}")
    print(f"--- Subject: {subject}")
    print(f"--- Body: {body}")
    print(f"--- Schedule Type: {scheduleType}")
    print(f"--- Start Date: {start}")
    print(f"--- End Date: {end}")
    print(f"--- Interruption Level: {interruptionLevel}")
    print(f"--- Signature: {signature}")
    return

def deleteAnnouncement(requestDict, announceNum):
    return

userCommand = ""
while (True):
    displayAllAnnouncements(userRequests)
    userCommand = input("What action would the user like to do? [v/d] ")
    if (userCommand.lower() == "v"):
        num = int(input("\nWhich announcement would you like to view? "))
        viewDetails(userRequests, num)
    elif (userCommand.lower() == "d"):
        num = int(input("Which announcement would you like to delete? "))
        deleteAnnouncement(userRequests, num)
    elif (userCommand.lower() in ["quit", "exit", "q", "x"]):
        break
    print()

