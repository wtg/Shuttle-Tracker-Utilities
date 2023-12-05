import tkinter as tk
from tkinter import messagebox
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
import cryptography.hazmat.primitives.serialization
import json
import requests
import uuid
import datetime
import base64
import os

def submit_announcement():
    subject_val = subject_entry.get().strip()
    body_val = body_entry.get().strip()
    schedule_type_val = schedule_type_entry.get().strip()
    interruption_level_val = interruption_level_entry.get().strip()
    start_val = start_entry.get().strip()
    end_val = end_entry.get().strip()

    start = datetime.datetime.now()
    end = start + datetime.timedelta(days=7)
    id = uuid.uuid4()
    serverChoice = server_choice_var.get()

    keyPath = key_path_entry.get().strip()
    generateKey = False

    if keyPath == "":
        user_choice = generate_key_var.get()
        if user_choice == 1:
            generateKey = True

    if generateKey:
        newPrivateKey = Ed25519PrivateKey.generate()
        privatePEM = newPrivateKey.private_bytes(
            encoding=cryptography.hazmat.primitives.serialization.Encoding.PEM,
            format=cryptography.hazmat.primitives.serialization.PrivateFormat.OpenSSH,
            encryption_algorithm=cryptography.hazmat.primitives.serialization.NoEncryption()
        )
        folderpath = os.path.expanduser("~/Documents/STKeys")
        keyPath = os.path.join(folderpath, "STprivatekey.pem")
        if not os.path.exists(folderpath):
            os.makedirs(folderpath)
        with open(keyPath, "wb") as private_key_file:
            private_key_file.write(privatePEM)

    inFile = open(keyPath, "rb")
    privateKeyFile = inFile.read()
    inFile.close()

    passphrase = passphrase_entry.get().strip()

    while True:
        try:
            if schedule_type_val == "startOnly" or schedule_type_val == "startAndEnd":
                startarr = start_val.split("-")
                start = datetime.datetime(int(startarr[0]), int(startarr[1]), int(startarr[2]), int(startarr[3]), int(startarr[4]), 00)
                break
            elif schedule_type_val == "endOnly" or schedule_type_val == "startAndEnd":
                endarr = end_val.split("-")
                end = datetime.datetime(int(endarr[0]), int(endarr[1]), int(endarr[2]), int(endarr[3]), int(endarr[4]), 00)
                break
            raise Exception(f"Unknown Schedule Type entered: {schedule_type_val}")
        except Exception as e:
            print("Error: ", e)

    start = start.replace(microsecond=00)
    end = end.replace(microsecond=00)
    start = start.isoformat() + "Z"
    end = end.isoformat() + "Z"

    while True:
        try:
            if interruption_level_val not in ["passive", "active", "timeSensitive", "critical"]:
                raise Exception(f"Unknown Interruption Level entered: {interruption_level_val}")
            break
        except Exception as e:
            print("Error: ", e)

    announcement_dict = {
        "scheduleType": schedule_type_val,
        "subject": subject_val,
        "end": end,
        "interruptionLevel": interruption_level_val,
        "body": body_val,
        "start": start,
        "id": str(id)
    }

    if passphrase == 'n':
        privateKey = cryptography.hazmat.primitives.serialization.load_ssh_private_key(privateKeyFile, None)
    else:
        passphrase = bytes(passphrase, 'utf-8')
        privateKey = cryptography.hazmat.primitives.serialization.load_ssh_private_key(privateKeyFile, passphrase)

    def post_announcement():
        concat = bytes(announcement_dict["subject"] + announcement_dict["body"], 'utf-8')
        signed_key = privateKey.sign(concat)
        signature = base64.b64encode(signed_key).decode()
        announcement_dict["signature"] = signature
        r = None
        if serverChoice in ["s", "staging"]:
            r = requests.post("https://staging.shuttletracker.app/announcements", data=json.dumps(announcement_dict))
        elif serverChoice in ["p", "production"]:
            r = requests.post("https://shuttletracker.app/announcements", data=json.dumps(announcement_dict))
        if r.status_code == 403:
            print("Error Code 403: Signature was rejected, try another signing key.\n")
        elif r.status_code == 200:
            print("Submission has been accepted.")
        else:
            print(f"Error code {r.status_code}: Aborted due to some unexpected error.")
        return

    post_announcement()

