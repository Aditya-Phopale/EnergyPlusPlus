// const floor_plan_button = document.querySelector("div.next-page-button button");

var xhr = null;
var uploaded_image = null;

getXmlHttpRequestObject = function () {
  if (!xhr) {
      // Create a new XMLHttpRequest object 
      xhr = new XMLHttpRequest();
  }
  return xhr;
};

// // show the image from yolov5
// floor_plan_button.addEventListener("click", function() {
//   // this element is supposed to first call requestRooms
//   requestRooms();
//   alert('made it to floor plan button')
//   // check if the processing of the image was complete
//   if (xhr.steadyState == 4 && xhr.status == 201){
//     // plot the result from file 
//     show_image('../backend/2R1C_simulation/plot.png', 
//                  500, 
//                  400, 
//                  'The result of the modelling');
//   }
// });


function requestRooms(){
  console.log("Sending the rooms request");
  xhr = getXmlHttpRequestObject();
  // asynchronous request
  xhr.open("GET", "http://localhost:6969/rooms", true);
  // Send nothing
  xhr.send(null);
}
