from flask import Flask, request, jsonify
import os
import requests
import logging
from dotenv import load_dotenv
from helper import require_api_key
from services import fetch_population_data, request_country_details, invalidate_caches, population_cache
from config import * 

# Load environment variables
load_dotenv()
API_KEY = os.getenv("API_KEY")
POPULATION_API_URL = "https://restcountries.com/v3.1/name/"

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
app = Flask(__name__)


@app.route('/population/current/<country>', methods=['GET'])
@require_api_key
def get_current_population(country):
    """Fetch and return current population data"""
    logging.info(f"Request received: GET /population/current/{country}")
    population = fetch_population_data(country)
    if population is not None:
        population_cache[country] = population  # Cache the data
        return jsonify({"population": population})
    return jsonify({"error": "Country not found"}), 404

@app.route('/population/stats/<country>', methods=['GET'])
@require_api_key
def get_population_stats(country):
    """Return basic statistics from cached data"""
    logging.info(f"Request received: GET /population/stats/{country}")
    if country not in population_cache:
        return jsonify({"error": "No cached data available"}), 404

    population = population_cache[country]
    return jsonify({
        "country": country,
        "min_population": population,  # Since we store only one value
        "max_population": population,
        "avg_population": population
    })


@app.route('/population/details/<country>', methods=['GET'])
@require_api_key
def get_country_details(country):
    """Return basic stats such as region, subregion, and languages."""
    logging.info(f"Request received: GET /population/details/{country}")
    details = request_country_details(country)
    if details is None:
        return jsonify({"error": "Country not found"}), 404

    region = details.get("region", "Unknown")
    subregion = details.get("subregion", "Unknown")
    languages = details.get("languages", {})
    return jsonify({
        "country": country,
        "region": region,
        "subregion": subregion,
        "languages": languages
    })

@app.route('/population/invalidate', methods=['POST'])
@require_api_key
def invalidate_cache():
    """Invalidate all cached data."""
    logging.info("Request received: POST /population/invalidate")
    invalidate_caches()
    return jsonify({"message": "Caches invalidated"}), 200

@app.route('/healthz/')
def health():
    return jsonify({'message': 'Healthy'})  # This will return as JSON by default with a 200 status code

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
