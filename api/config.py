import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("API_KEY")
POPULATION_API_URL = "https://restcountries.com/v3.1/name/"
