# -*- coding: utf-8 -*-
"""
Created on Tue Jun  8 13:58:54 2021

@author: HLai
"""

t2a = "https://analog.crm.dynamics.com/main.aspx?appid=4283a7fa-79a8-e811-a843-000d3a37c848&etn=po_opportunityproduct&pagetype=entitylist&viewType=4230&viewid=%7B775920B9-6364-EB11-A812-000D3A32625B%7D"
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait;
from selenium.webdriver.common.action_chains import ActionChains;
import time;
import datetime;
import os;

Current_Date = datetime.datetime.today().strftime ('%Y-%m-%d');
folder = r'C:\Users\hlai\OneDrive - Analog Devices, Inc\Documents\Pipeline_PowerBI\Archive'
date_folder = folder + '\\'+Current_Date+'\\T2A';
if not os.path.exists(date_folder):
    os.makedirs(date_folder)

options = webdriver.ChromeOptions()
prefs = {"download.default_directory" : date_folder}
options.add_experimental_option("prefs",prefs)
options.add_argument("--start-maximized")
driver = webdriver.Chrome(ChromeDriverManager().install(), chrome_options=options)
#open browswer
action = ActionChains(driver);
driver.get(t2a);

wait = WebDriverWait(driver, 20)
time.sleep(3)

wait.until(lambda x:x.find_element_by_id('i0116')).send_keys("Hilary.Lai@analog.com")
wait.until(lambda x:x.find_element_by_id('idSIButton9')).click()
time.sleep(2)
wait.until(lambda x:x.find_element_by_id('passwordInput')).send_keys("Dabono1215!")
time.sleep(2)
wait.until(lambda x:x.find_element_by_id('submitButton')).click()
time.sleep(2)
wait.until(lambda x:x.find_element_by_id('idSIButton9')).click()

time.sleep(27)
export = wait.until(lambda x:x.find_element_by_xpath('//span[text()="Export to Excel"]'))
export.click()

import glob
import pandas as pd

timeout = time.time() + 60*20
while len(glob.glob(date_folder+"\\*.xlsx"))==0:
    time.sleep(1)
    if time.time() > timeout:
        break

if len(glob.glob(date_folder+"\\*.xlsx"))==1:
    for file in glob.glob(date_folder+"\\*.xlsx"):
        read_file = pd.read_excel(file)
        read_file.to_csv(r'C:\Users\hlai\Analog Devices, Inc\APR-Data-Team - Power BI Development\Project\pipeline\T2A.csv', index = None, header=True)
        driver.close()