#!/usr/bin/env python
# coding: utf-8

# Energy PLUS PLUS - ML Demo/ Graph Generation
from tkinter import *
import json
import cv2
import torch
from IPython.display import display
import PIL
import argparse


def visualize_result(saved_path):
    """
    Visualize the image after drawing bounding boxes.

    Args:
        saved_path str: path to the result saved after drawing bounding
        boxes on the image
    """
    im = cv2.imread(saved_path)
    resized = cv2.resize(im, (1200, 1500))
    cv2.imshow("PRED", resized)
    cv2.waitKey(0)
    display(PIL.Image.open("image0.png"))


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
    # TODO: The save directory is created every time a new image is predicted upon.
    # So this would result in result_folder1 result_folder2 and so on. It was using
    # sudo previously to remove the duplicate everytime but it is very hacky and needs
    # a better solution.
    result.render(labels=True)
    result.save(labels=True, save_dir="./result_folder")
    image = PIL.Image.open(saved_path)
    draw = PIL.ImageDraw.Draw(image)
    font = PIL.ImageFont.truetype("arial.ttf", 50, encoding="unic")
    for text, coordinates in zip(entity_labels, centers):
        # annotate each room and save with each annotation
        draw.text((coordinates[0], coordinates[1]), text, font=font, fill="#0000FF")
        image.save(saved_path, "png")
    draw.text([1, 5000], str(connectivity), font=font, fill="#0000FF")
    image.save(saved_path, "png")


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
    entity_labels = []
    room_count = 1
    window_count = 0
    door_count = 0
    # Add element names to the labels
    for row in result_array[0]:
        if int(row[-1]) == 0:
            entity_labels.append("room" + str(room_count))
            room_count += 1
        elif int(row[-1]) == 1:
            entity_labels.append("window" + str(window_count))
            window_count += 1
        else:
            entity_labels.append("door" + str(door_count))
            door_count += 1

    # reversing the list to make it consistent with detect.py results from the yolov5
    entity_labels = list(reversed(entity_labels))
    return entity_labels


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
    # percentage of overlap above which the rooms are considered neighbors
    IOU = 0.2
    # orthogonal overlap
    offset = 200.0
    # multiplication factor between pixels and image - empirically calculated for now
    x_factor = 1.68 * 100
    y_factor = 1.685 * 100
    # factor of change in area
    area_factor = x_factor * y_factor
    # height assumed constant for the moment
    height = 3.0
    # wll thickness - considered constant for the moment
    thickness = 0.25
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

    # array to store the centers of all bounding boxes - used later for labels
    centers = []
    # Finding connectivity and storing every connection with attributes of each room
    for i, one_room in enumerate(all_rooms):
        # coordinates of the bounding box of the single image to be matched against all others
        x1min, y1min, x1max, y1max = (
            one_room[0].item(),
            one_room[1].item(),
            one_room[2].item(),
            one_room[3].item(),
        )
        # centre of the bounding box
        x1c, y1c = (x1min + x1max) / 2, (y1min + y1max) / 2
        # collecting centers of each bounding box
        if (x1c, y1c) not in centers:
            centers.append((x1c, y1c))
        # area and volume of the room to be matched
        area = ((x1max - x1min) * (y1max - y1min)) / area_factor
        volume = area * height
        connectivity[entity_labels[i]]["area"] = area
        connectivity[entity_labels[i]]["volume"] = volume

        # Storing total bounding box length(perimeter) to calculate length of wall exposed to outside atmosphere
        perimeter = 2 * ((x1max - x1min) + (y1max - y1min))
        overall_overlap = 0.0
        # Comparing i th element with all others
        for j, one_room in enumerate(all_rooms):
            if i != j:
                x2min, y2min, x2max, y2max = (
                    one_room[0].item(),
                    one_room[1].item(),
                    one_room[2].item(),
                    one_room[3].item(),
                )
                # x2c, y2c = (x2min+x2max)/2 , (y2min + y2max)/2
                # check if the box i and j overlap on the "right" by offset amounts
                if abs(x1max - x2min) <= offset:
                    # standard iou technique - calculate overlap
                    overlap = abs(min(y1max, y2max) - max(y1min, y2min))
                    union = y1max - y1min + y2max - y2min - overlap
                    # the percentage of overlap is above IOU, consider it a true neighbor
                    intersection = overlap / union
                    # print("right", intersection)
                    if intersection > IOU:
                        # check for neighbors and add only if it has not been added yet
                        if (
                            entity_labels[i]
                            not in connectivity[entity_labels[j]]["neighbors"]
                            and entity_labels[j]
                            not in connectivity[entity_labels[i]]["neighbors"]
                        ):
                            connectivity[entity_labels[i]]["neighbors"].append(
                                entity_labels[j]
                            )
                            connectivity[entity_labels[i]]["wall"].append(
                                overlap / y_factor
                            )

                        overall_overlap = overall_overlap + overlap
                # check for left neighbors
                if abs(x1min - x2max) <= offset:
                    overlap = abs(min(y1max, y2max) - max(y1min, y2min))
                    union = y1max - y1min + y2max - y2min - overlap
                    intersection = overlap / union
                    # print("left", intersection)
                    if intersection > IOU:
                        # check for neighbors and add only if it has not been added yet
                        if (
                            entity_labels[i]
                            not in connectivity[entity_labels[j]]["neighbors"]
                            and entity_labels[j]
                            not in connectivity[entity_labels[i]]["neighbors"]
                        ):
                            connectivity[entity_labels[i]]["neighbors"].append(
                                entity_labels[j]
                            )
                            connectivity[entity_labels[i]]["wall"].append(
                                overlap // y_factor
                            )

                        overall_overlap = overall_overlap + overlap
                # check for top neighbors
                if abs(y1max - y2min) <= offset:
                    overlap = abs(min(x1max, x2max) - max(x1min, x2min))
                    union = x1max - x1min + x2max - x2min - overlap
                    intersection = overlap / union
                    # print("top", intersection)
                    if intersection > IOU:
                        # check for neighbors and add only if it has not been added yet
                        if (
                            entity_labels[i]
                            not in connectivity[entity_labels[j]]["neighbors"]
                            and entity_labels[j]
                            not in connectivity[entity_labels[i]]["neighbors"]
                        ):
                            connectivity[entity_labels[i]]["neighbors"].append(
                                entity_labels[j]
                            )
                            connectivity[entity_labels[i]]["wall"].append(
                                overlap / x_factor
                            )

                        overall_overlap = overall_overlap + overlap
                # check for bottom neighbors
                if abs(y1min - y2max) <= offset:
                    overlap = abs(min(x1max, x2max) - max(x1min, x2min))
                    union = x1max - x1min + x2max - x2min - overlap
                    intersection = overlap / union
                    # print("bottom", intersection)
                    if intersection > IOU:
                        # check for neighbors and add only if it has not been added yet
                        if (
                            entity_labels[i]
                            not in connectivity[entity_labels[j]]["neighbors"]
                            and entity_labels[j]
                            not in connectivity[entity_labels[i]]["neighbors"]
                        ):
                            connectivity[entity_labels[i]]["neighbors"].append(
                                entity_labels[j]
                            )
                            connectivity[entity_labels[i]]["wall"].append(
                                overlap / x_factor
                            )

                        overall_overlap = overall_overlap + overlap

        if overall_overlap < perimeter:
            connectivity[entity_labels[i]]["neighbors"].append("room0")
            connectivity[entity_labels[i]]["wall"].append(
                (perimeter - overall_overlap) / x_factor
            )
    return connectivity, entity_labels, centers


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
    img = cv2.imread(image_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    result = model(img)
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Arguments for script")
    parser.add_argument("--model_path", type=str, help="path to weight file")
    parser.add_argument("--image_path", type=str, help="path to image file")
    parser.add_argument("--saved_path", type=str, help="path to save the prediction")

    args = parser.parse_args()

    if args.image_path is not None:
        image_path = args.image_path
    else:
        image_path = "./test.png"
    if args.model_path is not None:
        model_path = args.model_path
    else:
        model_path = "./best.pt"
    if args.saved_path is not None:
        saved_path = args.saved_path
    else:
        saved_path = "./output.png"

    result = detect_rooms(image_path, model_path)
    # bb_dataframe = result.pandas().xyxy[0]
    connectivity_dict, entity_labels, centers = connect_all(result)
    save_result(result, connectivity_dict, entity_labels, centers, saved_path)
    # comment this out to turn off image pop up
    # visualize_result(saved_path)
    write_to_json(connectivity_dict)
	