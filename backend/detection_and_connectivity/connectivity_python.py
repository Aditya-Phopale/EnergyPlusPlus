# Copyright (c) 2023 EnergyPlusPlus, a collaboration between BGCE and Siemens. All rights reserved.

# Importing necessary libraries
from IPython.display import display
import platform
if platform.system() == 'Linux':
    from tkinter import *  # linux name
else:
    from tk import *  # MacOS name
import json
import PIL
import cv2
import torch
import os
import argparse

def detect_rooms(image_path, model_path):
    """
    Run the trained model to detect entities(rooms/doors/windows).

    Args:
        image_path str: Path to the image to be predicted upon
        model_path str: Path to the network weights

    Returns:
        model_output: The prediction from the model
    """

    print("RUNNING PYTHON SCRIPT...")
    model = torch.hub.load("ultralytics/yolov5", "custom", model_path)
    model.conf = 0.52
    # Evaluating the model on a test image
    model.eval()
    print(image_path)
    img = cv2.imread(image_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    result = model(img)
    return result

def add_labels(result_array):
    """
    Collect all possible labels in a prediction and add them into an array.

    Args:
        result_array NDArray: A numpy array of all the predictions with details
        on names and co-ordinates

    Returns:
        list: All entities named according to their order and
        added top the list
    """
    # Name of elements in the image - room/windows/doors etc
    # indices for elements
    labels = []
    room_count = 1
    window_count = 0
    door_count = 0
    # Add element names to the labels
    for row in result_array[0]:
        if int(row[-1]) == 0:
            labels.append("room" + str(room_count))
            room_count += 1
        # elif int(row[-1]) == 1:
        #    labels.append("window" + str(window_count))
        #    window_count += 1
        # else:
        #    labels.append("door" + str(door_count))
        #    door_count += 1

    # reversing the list to make it consistent with detect.py results from the yolov5
    labels = list(reversed(labels))
    return labels

def set_attributes(entity_labels):
    """
    Set the fundamental attributes common to each entity as a dictionary
    Args:
        entity_labels list: A list of each label in the prediction

    Returns:
        dict: Connectivity dictionary with only initialized values but no connecting
        neighbor information.
    """
    # setting attributes for each room
    connectivity = {}
    for idx, each_label in enumerate(entity_labels):
        connectivity[each_label] = {
            "neighbors": [],
            "wall": [],
            "area": 0.0,
            "thickness": 0.25,
            "volume": 0.0,
        }
    return connectivity

def visualize_result(saved_path):
    """
    Visualize the image after drawing bounding boxes.

    Args:
        saved_path str: path to the result saved after drawing bounding
        boxes on the image
    """

    print(saved_path +"detection_and_connectivity/images/boxed_ordered_rooms.png")
    im = cv2.imread(saved_path +"/images/boxed_ordered_rooms.png")
    resized = cv2.resize(im, (640, 480))
    cv2.imshow("PRED", resized)
    cv2.waitKey(0)


def save_result(result, connectivity, entity_labels, centers, saved_path):
    """
    Save image of floor plan with entity labels to saved_path.

    Args:
        result model_output: Result of the trained model
        connectivity dict: Dictionary which defines the connectivity of the floor plan
        entity_labels list: Label name collection for each entity in a floor plan
        centers list: List of center of entities of a floor plan
        saved_path str: Path where the image is saved
    """

    # Rendering the image with bounding boxes
    FIG_PATH = "images/"
    os.chdir("detection_and_connectivity")
    filename = "floor_plan.png"
    floors_image = cv2.imread(FIG_PATH + filename)

    result.render(labels=True)
    result.save(labels=True, save_dir="./")
    os.system("mv './.2/image0.jpg' " + FIG_PATH + "boxed_rooms.jpg")
    os.system("rmdir ./.2")
    image = PIL.Image.open(FIG_PATH + "boxed_rooms.jpg")
    draw = PIL.ImageDraw.Draw(image)
    font = PIL.ImageFont.truetype("arial.ttf", 50, encoding="unic")
    for text, coordinates in zip(entity_labels, centers):
        # annotate each room and save with each annotation
        draw.text((coordinates[0], coordinates[1]),
                  text, font=font, fill="#0000FF")
        image.save(FIG_PATH + "boxed_ordered_rooms.png", "png")
    draw.text([1, 5000], str(connectivity), font=font, fill="#0000FF")
    image.save(FIG_PATH + "boxed_ordered_rooms.png", "png")
    # display(PIL.Image.open(FIG_PATH + "boxed_ordered_rooms.png"))


# Writing connnectivity into json file
def write_to_json(connectivity):
    """
    Write connectivity details obtained from the rule based detection into
    a JSON file
    Args:
        connectivity dict: A dictionary with information about connectivity
    """
    with open("connectivity.json", "w+") as f:
        json.dump(connectivity, f)
    print("GRAPH WRITTEN TO JSON file")
    os.chdir("../")

def connect_neighbors(
    connectivity,
    current_coordinates,
    neighbor_coordinates,
    current_room_components,
    neighbor_room_components,
    mult_factors,
):
    """
    Connect one room with all of its neighbors.

    Args:
        directions list[str]: list of directions
        connectivity dict: Connectivity dictionary
        current_coordinates tuple(int): current xmin, ymin, xmax
        and ymax
        neighbor_coordinates tuple(int): potential Neighbor xmin,
        ymin, xmax, ymax
        current_room_components list: All components of room including its
        name and area,vol etc.
        neighbor_room_components list: All components of room including its
        name and area,vol etc.
        mult_factors list: Scaling factor in x and y direction

    Returns:
        overall_overlap: _description_
    """
    directions = ["right", "left", "top", "bottom"]
    # percentage of overlap above which the rooms are considered neighbors
    IOU = 0.2
    # orthogonal overlap
    offset = 200.0
    x1min, y1min, x1max, y1max = current_coordinates
    x2min, y2min, x2max, y2max = neighbor_coordinates
    one_side_overlap = 0.0
    for idx, direction in enumerate(directions):
        overlap = 0.0
        union = -1.0
        if direction == "right":
            offset_x = x1max - x2min
            offset_y = 0
        if direction == "left":
            offset_x = x1min - x2max
            offset_y = 0
        if direction == "top":
            offset_x = 0
            offset_y = y1max - y2min
        if direction == "bottom":
            offset_x = 0
            offset_y = y1min - y2max
        if abs(offset_x) <= offset or abs(offset_y) <= offset:
            if abs(offset_x) > 0 and abs(offset_x) <= offset:
                overlap = min(y1max, y2max) - max(y1min, y2min)
                union = y1max - y1min + y2max - y2min - overlap
            if abs(offset_y) > 0 and abs(offset_y) <= offset:
                overlap = min(x1max, x2max) - max(x1min, x2min)
                union = x1max - x1min + x2max - x2min - overlap
            intersection = overlap / union
            if intersection > IOU:
                # check for neighbors and add only if it has not been added yet
                if (
                    current_room_components
                    not in connectivity[neighbor_room_components]["neighbors"]
                    and neighbor_room_components
                    not in connectivity[current_room_components]["neighbors"]
                ):
                    connectivity[current_room_components]["neighbors"].append(
                        neighbor_room_components
                    )
                    connectivity[current_room_components]["wall"].append(
                        overlap / mult_factors[idx]
                    )
                one_side_overlap += overlap
    return one_side_overlap

def add_ambient_node(connectivity, current_room_component, wall_length):
    """
    Add ambient node if the outer wall is exposed significantly.

    Args:
        connectivity dict: Connectivity dictionary
        current_room_component list: list of all components of the current room
        wall_length float: length of wall exposed to ambient condition
    """
    connectivity[current_room_component]["neighbors"].append("room0")
    connectivity[current_room_component]["wall"].append(wall_length)


def connect_all(result):
    """
    Use rule based connectivity to connect entities that have been detected
    by the network.

    Args:
        result model_output: Prediction of the network on the image

    Returns:
        tuple[dict, list, list]: A tuple with connectivity dictionary, the entity labels
        list and the list of center of each element
    """
    # multiplication factor between pixels and image - empirically calculated for now
    x_factor = 1.68 * 100
    y_factor = 1.685 * 100
    # factor of change in area
    area_factor = x_factor * y_factor
    # height assumed constant for the moment
    height = 3.0
    # wall thickness - considered constant for the moment
    thickness = 0.25
    # Boolean to specify whether the roof boundary condition should be applied to a floor plan
    # By default floor plan does not have roof
    # if true change ki to -0.3 and kd to 1000 and increase maximum heating to 1200
    has_roof = False
    # volume to be calculated
    volume = 0.0
    # Numpy array of results from model
    result_array = result.pred
    # get name of all the components of the floor plan in a list
    entity_labels = add_labels(result_array)
    # Add just the name of the detected components of the floor plan such as
    # door, window, room etc. to the list of labels
    entity_labels = add_labels(result_array)
    # Set attributes for each entity in the Graph for connectivity of rooms
    connectivity = set_attributes(entity_labels)
    # access the numpy array of results - result_val is a list with length 1 - the 0th element is the prediction
    all_rooms = result_array[0]
    mask = all_rooms[:, -1] == 0
    all_rooms = all_rooms[mask, :]
    # array to store the centers of all bounding boxes - used later for labels
    centers = []
    # Finding connectivity and storing every connection with attributes of each room
    for i, current_room in enumerate(all_rooms):
        # coordinates of the bounding box of the single image to be matched against all others
        current_coordinates = x1min, y1min, x1max, y1max = (
            current_room[0].item(),
            current_room[1].item(),
            current_room[2].item(),
            current_room[3].item(),
        )
        centers.append(((x1min+x1max)/2, (y1min+y1max)/2))
        area = ((x1max - x1min) * (y1max - y1min)) / area_factor
        volume = area * height
        connectivity[entity_labels[i]]["area"] = area
        connectivity[entity_labels[i]]["volume"] = volume
        # Storing total bounding box length(perimeter) to calculate length of wall exposed to outside atmosphere
        perimeter = 2 * ((x1max - x1min) + (y1max - y1min))
        overall_overlap = 0.0
        # Comparing i th element with all others
        for j, potential_neighbor in enumerate(all_rooms):
            if i != j:
                neighbor_coordinates = (
                    potential_neighbor[0].item(),
                    potential_neighbor[1].item(),
                    potential_neighbor[2].item(),
                    potential_neighbor[3].item(),
                )
                # x2c, y2c = (x2min+x2max)/2 , (y2min + y2max)/2
                # check if the box i and j overlap on the "right" by offset amounts
                mult_factors = [y_factor, y_factor, x_factor, x_factor]
                current_room_components = entity_labels[i]
                neighbor_room_components = entity_labels[j]
                overall_overlap += connect_neighbors(
                    connectivity,
                    current_coordinates,
                    neighbor_coordinates,
                    current_room_components,
                    neighbor_room_components,
                    mult_factors,
                )
        wall_length = (perimeter - overall_overlap) / x_factor
        # Checking if a floor plan has roof then connect to ambient with wall_area = room_area
        if has_roof == True:
            # Roof area exposed to ambient stored as area/height to maintain consistency with the previous ambient connection where wall length was stored.
            # In the model setup in connectivity_julia file all the wall lengths are multiplied with height to get the area of wall.
            wall_length += area/height
        # Checking if any part of wall is exposed to ambient
        if overall_overlap < perimeter:
            add_ambient_node(
                connectivity, current_room_components, wall_length)
    return connectivity, entity_labels, centers

def run():
    parser = argparse.ArgumentParser(description="Arguments for script")
    parser.add_argument("--model_path", type=str, help="path to weight file")
    parser.add_argument("--image_path", type=str, help="path to image file")
    parser.add_argument("--saved_path", type=str, help="path to save the prediction")

    args = parser.parse_args()

    if args.image_path is not None:
        image_path = args.image_path
    else:
        image_path = "detection_and_connectivity/images/floor_plan.png"
        
    if args.model_path is not None:
        model_path = args.model_path
    else:
        model_path = "detection_and_connectivity/best.pt"
        
    if args.saved_path is not None:
        saved_path = args.saved_path
    else:
        saved_path = "./"
        
    result = detect_rooms(image_path, model_path)
    # bb_dataframe = result.pandas().xyxy[0]
    connectivity_dict, entity_labels, centers = connect_all(result)
    # comment the folllowing 2 lines out if only json is required - does not effect json results
    save_result(result, connectivity_dict, entity_labels, centers, saved_path)
    # visualize_result(saved_path) # image pop up
    write_to_json(connectivity_dict)

if __name__ == "__main__":
    run()