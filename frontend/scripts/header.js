var xhr = null;
var uploaded_image = null;

getXmlHttpRequestObject = function () {
  if (!xhr) {
      // Create a new XMLHttpRequest object 
      xhr = new XMLHttpRequest();
  }
  return xhr;
};

//https://stackoverflow.com/questions/5451445/how-to-display-image-with-javascript
function show_image(src, width, height, alt) {
  var img = document.createElement("img");
  img.src = src;
  img.width = width;
  img.height = height;
  img.alt = alt;

  // This next line will just add it to the <body> tag
  document.body.appendChild(img);
}

function switch_to_page(src){
//  if (xhr.status == 201 || xhr.status == 500){
    location.href=src;
//  }
}

function Sleep(milliseconds) {
  return new Promise(resolve => setTimeout(resolve, milliseconds));
 }

//  async function waiting(){ 
//     console.log("before sleep Function");
//     document.write("<span class='loader'></span>")

//     await Sleep(3000);
//     // TODO: add some kind of wait for the update
//     show_image('../images/labels_cropped.png', 
//                             300, 
//                             400, 
//                             'The detected rooms of the building plan');
// }


async function show_picture_waiting(img, width, height){ 
    console.log("before sleep Function");

    const loader_element = document.getElementById("loader_link");

    //document.write("<span class='loader'></span>")
    var span_elem = document.createElement("span")
    span_elem.setAttribute('class', 'loader')

    loader_element.appendChild(span_elem);

    await Sleep(3000);
    loader_element.remove();
    show_image(img, 
                width, 
                height, 
                'The detected rooms of the building plan');
}