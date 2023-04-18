import * as React from "react"
import { Link } from "gatsby"
import { StaticImage } from "gatsby-plugin-image"

import Layout from "../components/layout"
import {Seo} from "../components/seo"

const Model = () => (
  <Layout>
      <div className="container text-center my-5">
          <h1> Results of default floor plan 1</h1>
          <br/>
          <p>The computation can take some time. Please refresh the website to see the results.</p>
      </div>

      <div class = "container">
          <div className="row">
          <div class="col">
          <h2> Recognized Rooms </h2>
          <p> Here is the result for the recognition of the rooms of your building:</p>

          <StaticImage
              src="../images/Default_floorplans/1.png"
              width={500}
              quality={95}
              formats={["AUTO", "WEBP"]}
              alt="labeled floor plan"
              className="img-fluid"
          />
          </div>

          <div className="col">
          <h2> Connectivity Graph </h2>
          <p> Here is the detected connectivity graph:</p>
          <StaticImage
              src="../images/Default_floorplans/graph_viz_1.png"
              width={500}
              quality={100}
              formats={["AUTO", "WEBP"]}
              alt="modelling results"
              className="img-fluid"
          />
          </div>

          <div className="col">
          <h2> Modelling</h2>
          <p> Here is a simulation of your model:</p>
          <StaticImage
                src="../images/Default_floorplans/Prototype_Model_Simple_1.png"
                width={500}
                quality={100}
                formats={["AUTO", "WEBP"]}
                alt="modelling results"
                className="img-fluid"
              />
      </div>
      </div>
          <div className="row">
              <Link to="/start" className="btn btn-primary my-2">Try another floor plan</Link>
          </div>
      </div>
  </Layout>

)

export default Model



export const Head = () => (
    <Seo title="Results" />
)

