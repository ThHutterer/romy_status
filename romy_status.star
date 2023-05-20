"""
Applet: OPNV Austria
Summary: Austria public transport departure times from any stop 
Description: Next departures from any stop in Austria. Uses the VAO API. https://www.verkehrsauskunft.at/start"
Author: Thomas Hutterer
"""

load("encoding/base64.star", "base64")
load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")
load("encoding/json.star", "json")

BASE_URL = "{ip}"
DEFAULT_PWD = None
DEFAULT_IP = None
FLASH_IMG = base64.decode("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAA3NCSVQICAjb4U/gAAAACXBIWXMAAABvAAAAbwHxotxDAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAANJQTFRF////AAAAAAAAAAAAAAAAAAAAAAAAgE0JAAAACAgAFRAAGBgJPigAGxgANjYdHBYAHhsAJiADJB8DKSQCMB8CNCoCLSgCMywCMCkBPC4DSUQoSzwDNC4DR0IrTD0CTUowT0owRzYCTzkCWk4ERz4CSTgCYD4DY1UDHRoBTzsDYEcDHRkBbWY8m4cFg3IEglwEFA4BpXAFk5GBlJKClZOClpSDw50Hi1oEyIIG3sEI4JEH6ssI89MJ9qMI+O6y+e+z/q8I/roI/sQJ/9sJ/90J/+Q7QofzAAAAADp0Uk5TAAEECAsPFx4iIjE2OkFQU1RXYmt1mKCqtry/v8TMzdPT1NTU1tve3uLn6ert7vDz9/r7+/v7+/z9/pD1E78AAAB9SURBVBgZVcFVFsIwAATAxSVIcYdSpLi7Fdnc/0p8kNeEGSitmetO4/CJjeS5DK3zIPth+MRWcm5Bsz1eq9DETnLRbDhZKLZH8nMfRPAj9pLkc5KAkqlXRrfXMg0t2HuvCzDkD6cSTO1LLQBD6tgNwTQcR2GKrZL4U8xB+wLfHQ3SQPdOQwAAAABJRU5ErkJggg==")
BATTERY_IMG = base64.decode("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAAdgAAAHYBTnsmCAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAFQSURBVDiNzY87SANBFEXvzI6bKGbND4KSj2BjSkttxDql2vlJF7VWu8BiG0QQOwkqWtgoiKQQJGARrdRCkGCQLcQmBKIkzMZNdsZCUBYLFxu95eWc97jAX4fouk4N4ZsgsIOuLUrvdvXlMgCQ+WxuPxYJz0SCAVeulBKVp2e7yc3JnbWVE5LO5t42VxfVglFA3aw74Kg/Bs3rc3SDWhxGpY690/MLodhzDIDq9ajYvsx/++bxq1A8zNGN9Y9iNpHGyPDQ+E35sURd7/4agUgogIWpFAgwwDqWBc65e11KcM4hhEDHahPW4k1Uq1XXB4QQn3yLN8gvJgCEENReGwAIGEAAAPFwHK226QCjoSj6ejRHl+xNovbSwMbBkc1UNc+oQs3bB6M7k1hy9V1aEmdX11AUVjxc1zOMqV2p42JpS0poP+sfoYTcK2067Zb/53kHixFzwJ0OLJAAAAAASUVORK5CYII=")
STATUS_IMG = base64.decode("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAAdgAAAHYBTnsmCAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAHxSURBVDiNjZJNSFRRGIaf813u3DtmERXYD7WU0CCsARclOQVKtZdahlIb0YJAAhcD0c8umVW1qdw1q4oih2LEshhsSLA/IijJkloYuciZc+7cc1tko5WTvstzzvOc7zvng+XyYdhn6mm82rb8s3I7n+Tek7vkHvcAMEOe2eIs7x5k+ZTdX12QyTjcKAxQVDkCacM4IQDaOYuWIYy0UlIP+Xw/TZSqcKoiSI9fwrcn8cMcvhyjI/Hxj6vGRrZSW76GFx7Aj9Jsae9dEJx/uYdYOIpvh3HDdk4kgiUbfpWJIeuG8Gwr8XKSTYdGfpWiVRdGDIHTVRUGaOwwGLcTLWW0e3qhgjNv6vGijaQaHlWFF2cilyVmWwi/rRWOT9eg1WWMOCuCAUpqAqPiyOrNQjC3Hi1JtDq8YoFxPLSA9UuC+/0LRubQ0rRigZadBPKDhtavwtVEgFZZtNpH99vty8J3xhoxqoWSuoVS0fwvuBcwSjBynVNTVceWK4UaigyixVKWAfg9iTe3PUM75zDSTLE4Qs/rHUvAGxA1ilG7CJwUbXsLsHgSiRRHJ1P4th/PQtzm8exzPAu+1bjROPHyIJ7tp3P3RZSK/hLM58hkE6tsH7HwIJ5dg2/BC6epDeuJl3y6m2eWfadKet/X0fui7n9HfgIBBLcOyYOpywAAAABJRU5ErkJggg==")

def main(config):
    """main function of the app"""

    ip = config.get("ip", DEFAULT_IP)
    pwd = config.get("pwd", DEFAULT_PWD)

    unlock_dict = unlock_http_api(config)
    status_dict = get_romy_status(config)

    if ((unlock_dict["error"] != "") or (status_dict["error"] != "")):
        return error_render()
    else:
        return success_render(status_dict)



def unlock_http_api(config):
    """unlocks the HTTP API of Romy

    Args:
        config: the config dict of the app
    Returns:
        response_dict: a dict with the error message if there was an error, else None """

    response_dict = {"error": ""}
    rest_call_unlock_http = BASE_URL.format(
        ip = config.get("ip", DEFAULT_IP),
    ) + "set/unlock_http?pass=" + config.get("pwd", DEFAULT_PWD)

    #print(rest_call_unlock_http)
    response = http.get(rest_call_unlock_http, ttl_seconds = 604800)

    if response.status_code != 200:
        response_dict["error"] = "Error code {statuscode} when trying to unlock your Romy API".format(
            statuscode = response.status_code
        )

    return response_dict

def get_romy_status(config):

    response_dict = {"error": "",
                    "mode": "",
                    "battery level": "",
                    "charging status": ""
                    }

    rest_call_get_status = BASE_URL.format(
        ip = config.get("ip", DEFAULT_IP),
    ) + "get/status"

    #print(rest_call_get_status)

    response = http.get(rest_call_get_status, ttl_seconds = 10)
    if response.status_code != 200:
        response_dict["error"] = "Error code {statuscode} when trying to unlock your Romy API".format(
            statuscode = response.status_code
        )
        #print(response.status_code)
        return response_dict

    data = json.decode(response.body())
    #print(response.status_code)
    #print(data)
    response_dict["mode"] = data["mode"]
    response_dict["battery level"] = data["battery_level"]
    response_dict["charging status"] = data["charging"]

    return response_dict

def success_render(status_dict):
    result = render.Root(
        child = render.Column(
            children = [
                render.Row(
                    expanded = True,
                    main_align = "space_between",
                    cross_align = "center",
                    children = [
                        render.Image(src=STATUS_IMG, width = 10, height = 10),
                        render.Text(status_dict["mode"]),
                    ]
                ),
                render.Row(
                    expanded = True,
                    main_align = "space_between",
                    cross_align = "center",
                    children = [
                        render.Image(src=BATTERY_IMG, width = 10, height = 10),
                        render.Text(str(status_dict["battery level"]) + "%"),
                    ],
                ),
                render.Row(
                    expanded = True,
                    main_align = "space_between",
                    cross_align = "center",
                    children = [
                        render.Image(src=FLASH_IMG, width = 10, height = 10),
                        render.Text(status_dict["charging status"]),
                    ],
                ),
            ]
        )
    )

    return result

def error_render():       
    result = render.Root(
        child = render.WrappedText(
        content = "An error occured when trying to connect",
        color = "#FF000C",
        align = "left"
        )
    )
    return result

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