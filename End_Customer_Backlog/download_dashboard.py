# -*- coding: utf-8 -*-
"""
Created on Fri Jan 29 14:11:52 2021

@author: HLai
"""

url = "https://qv.web.analog.com/QvAJAXZfc/opendoc.htm?document=ops%5Fworld%5Cdisti%20ec%20bl%20support.qvw&bookmark=Server\BM167-28&host=QVS@QVCluster"
from selenium import webdriver
from selenium.webdriver.common.by import By;
from selenium.webdriver.support.ui import WebDriverWait;
from selenium.webdriver.support import expected_conditions as ec;
from selenium.webdriver.common.action_chains import ActionChains;
import time;
import datetime;
import os;

Current_Date = datetime.datetime.today().strftime ('%Y-%m-%d');
folder = r'C:\Users\hlai\OneDrive - Analog Devices, Inc\Documents\PCM\ECBL_POS_INV\ECBL\Clean_up\History'
date_folder = folder + '\\'+Current_Date;
if not os.path.exists(date_folder):
    os.makedirs(date_folder)

options = webdriver.ChromeOptions()
options.add_argument("--start-maximized");
prefs = {"download.default_directory" : date_folder}
options.add_experimental_option("prefs",prefs)
driver = webdriver.Chrome(chrome_options=options);

action = ActionChains(driver);
driver.get(url);
time.sleep(10)
wait = WebDriverWait(driver, 30)
report = wait.until(ec.presence_of_element_located((By.XPATH, '//div[@title = "Send to Excel"]')))
action.move_to_element(report).click(report).perform()