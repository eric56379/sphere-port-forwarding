# Port Forwarding Setup for Deterlab

Before running the setup, make sure that you have retrieved the port-forward-setup.sh script from me on Slack. Put this in the home directory of your XDC, and run ```sudo chmod 777 port-forward-setup```.

### Setup:
1. Run ```./port-forward-setup``` on Deterlab. You must be in your XDC. You may need to run ```sudo chmod 777 port-forward-setup``` in order to execute the script. You can get this fron Slack under #announcements.
2. Access your ```/home/user``` directory on the left sidebar of Jupyter. The output of the script will be titled "port-forward-data.zip".
3. Right-click on ```port-forward-data.zip```, then click on "Download". It will download to your machine.
4. For security, delete the ```port-forward-data.zip``` file from your XDC.
5. Extract ```port-forward-data.zip``` onto your machine.
6. Follow the instructions below based on your operating system:
- Mac/Linux users: Open a terminal window and navigate to the folder that you had just extracted. Type ```./port-forwarding-unix.sh```.
- Windows 10/11 users: Navigate to the folder that you extracted. Right-click on ```port-forwarding-windows.ps1```, and click "Run with PowerShell". Once the script completes, press Enter or close the window manually. <ins>If the window closes instantly</ins>, open Command Prompt or Powershell and type ```powershell -ExecutionPolicy Bypass -File .\path\to\port-forward-windows.ps1```.

  - **Note**: If you are experiencing issues with running the script(s), you may do Step 6 manually. Simply navigate to your home directory if you're on Unix (or ```C:\Users\username``` if you're on Windows), and locate a folder called ```.ssh```. You will need to be able to view hidden files for this. If the folder doesn't exist, create it. Navigate into ```.ssh``` and put ```config``` and ```merge_key``` into your folder. These are in the zip file that you downloaded.

7. Delete all of your extracted files when you are done. They are no longer required.

### How to Run:
1. To access your XDC <ins>without</ins> port-forwarding, you can type ```ssh username-xdc-proj``` in your terminal (or command prompt or PowerShell if you're on Windows).
- Example: ```ssh umdsecXX-xdc-umdsecXX``` where umdsecXX is the name of the user and the name of the project, with xdc being the name of the XDC.
2. To access your XDC <ins>with</ins> port-forwarding, you can type ```ssh -L port:node:80 username-xdc-proj```
- Example: ```ssh -L 8080:pathname:80 umdsecXX-xdc-umdsecXX``` where umdsecXX is the name of the user and the name of the project, with xdc being the name of the node. 8080 is an arbitrary number and can be a random four-digit number. node is the name of the materialization's node that you want to connect to. <ins>Read your lab manual if you're unsure what the name of your node is.<ins>
3. You will be asked to add two footprints when SSH'ing your first time. Type ```yes``` when prompted. The first one is to add Merge as a recognized host. The second one is to add your XDC as a recognized host. This only needs to be done once.
4. <ins>If you are port-forwarding</ins>: Open a web browser and navigate to ```localhost:port```, where ```port``` is the number that you used when running the command from Step 2. For example: ```localhost:8080``` would be typed into the address bar. 

### Additional Notes:
- You are unable to do port-forwarding with more than one account. If you need to change accounts, please delete the ```Host mergejump``` and ```Host username-xdc-proj``` segments from your ```config``` file and delete your ```merge_key``` file, both of which are located in ```~/.ssh/``` (for Mac/Linux) or ```C:\Users\username\.ssh``` (for Windows). Then, re-run the setup above.
- If you are receiving an error which looks like ```Permission denied (publickey,keyboard-interactive)```, navigate to ```~/.ssh``` on your XDC and see if there's an ```authorized_keys``` file missing. If there is, create a new one with ```touch authorized_keys; sudo chmod 644 authorized_keys```, then run ```sudo cat merge_key.pub >> authorized_keys``` and try to SSH again.
