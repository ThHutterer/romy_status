load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")
load("encoding/json.star", "json")



def main(config):
    """main function of the app"""
    ip = config.get["ip"]
    pwd = config.get["pwd"]
    base_url = "http://" + ip + ":8080/"

    unlock_dict = unlock_http_api()
    status_dict = get_romy_status()

def unlock_http_api(base_url, pwd):
    """unlocks the HTTP API of Romy

    Args:
        base_url (str): the base url of the Romy
        pwd (str): the password to unlock the HTTP API
    Returns:
        response_dict: a dict with the error message if there was an error, else None """

    response_dict = {"error": None}
    response = http.get(base_url + "set/unlock_http?pass=" + pwd, ttl_seconds = 604800)
    if response.status_code != 200:
        response_dict["error"] = "Error code {statuscode} when trying to unlock your Romy API".format(
            statuscode = response.status_code
        )
    return response_dict

def get_romy_status():
    """gets the status of the Romy

    Returns:
        response_dict: a dict with the error message if there was an error, else None """
    
    response_dict = {"error": None,
                    "mode": None,
                    "battery level": None,
                    "charging status": None
                    }

    response = http.get(base_url + "get/status", ttl_seconds = 15)
    if response.status_code != 200:
        response_dict["error"] = "Error code {statuscode} when trying to unlock your Romy API".format(
            statuscode = response.status_code
        )
        return response_dict

    data = json.decode(response.body())
    print(data)
    return response_dict

def get_schema():
    """returns the schema of the app"""
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "ip",
                name = "Romy's IP Address",
                desc = "The IP address of the Romy you want to control",
                icon = "gear"
            ),
            schema.Text(
                id = "pwd",
                name = "Romy's HTTP Unlock Password",
                desc = "This password is used to unlock the HTTP API of Romy",
                icon = "locationDot",
            ),

        ],
    )