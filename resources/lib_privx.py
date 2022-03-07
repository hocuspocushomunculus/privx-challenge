#!/usr/bin/env python3
"""
Collection of keywords used during PrivX challenge robot test
"""

import json
import logging
import requests

from variables import REST_API_URL, DEFAULT_ITEMS

def initialize_item_database():
    """
    Before each test case, make sure the item database
    has only but all of DEFAULT_ITEMS.
    Benefit is, we are able to run the test suite multiple
    times without having to restart the REST API server docker container.
    """
    current_items = json.loads(requests.get(REST_API_URL + "items/").text)

    if current_items != DEFAULT_ITEMS:
        logging.info("Current items are not equal to DEFAULT_ITEMS, restoring database state.")

        # Delete everything
        for item in current_items:
            response = requests.delete(REST_API_URL + "items/" + item["name"])
            assert response.status_code == 204, \
                f"Something went wrong when trying to delete {item} during initialization."

        # Restore default items
        for item in DEFAULT_ITEMS:
            response = requests.post(REST_API_URL + "items/", json=item)
            assert response.status_code == 201, \
                f"Something went wrong when trying to add {item} during initialization."
