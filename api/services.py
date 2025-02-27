import requests
import logging
from config import POPULATION_API_URL


# In-memory cache
population_cache = {}
country_details_cache = {}

def request_population_from_external(country):
    """Fetch current country information data from an external API with error handling"""
    try:
        response = requests.get(f"{POPULATION_API_URL}{country}", timeout=5)
        response.raise_for_status()  # Raises an error for non-200 responses
    except requests.exceptions.RequestException as e:
        logging.error(f"Error fetching population data for {country}: {e}")
        return None
    
    try:
        data = response.json()
    except ValueError as e:
        logging.error(f"Error parsing JSON response for {country}: {e}")
        return None

    if data:
        population = data[0].get("population", None)
        if population is not None:
            population_cache[country] = population
            return population
    return None

def fetch_population_data(country):
    if country in population_cache:
        logging.info(f"Population cache hit for {country}")
        return population_cache[country]
    logging.info(f"Population cache miss for {country}")
    return request_population_from_external(country)


def request_country_details(country):
    """Fetch detailed country data (region, subregion, languages) from an external API with error handling."""
    if country in country_details_cache:
        logging.info(f"Details cache hit for {country}")
        return country_details_cache[country]
    try:
        logging.info(f"Details cache miss for {country}")
        response = requests.get(f"{POPULATION_API_URL}{country}", timeout=5)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        logging.error(f"Error fetching country details for {country}: {e}")
        return None
    try:
        data = response.json()
    except ValueError as e:
        logging.error(f"Error parsing JSON response for {country}: {e}")
        return None
    if data:
        details = data[0]
        country_details_cache[country] = details
        return details
    return None

def invalidate_caches():
    """Clear all in-memory caches."""
    population_cache.clear()
    country_details_cache.clear()
    logging.warn("All caches have been invalidated.")
