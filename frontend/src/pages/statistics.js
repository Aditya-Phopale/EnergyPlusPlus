import * as React from "react";
import { Link } from "gatsby";

import Layout from "../components/layout";
import { Seo } from "../components/seo";

const sendStatistics = e => {
  // send http request to a local server to post values

  // that's how to access them:
  // document.getElementById("outside_thickness");
  // document.getElementById("inside_thickness");
  // document.getElementById("scaling");
}

const Start = () => {
  return (
    <Layout>
      <div className="container text-center my-5">
        <h1> Provide floor data </h1>
        <p> Fill in general information: </p>
        <br />
        <br />
        <p>
          <label for="scaling">Scaling factor of the building plan:</label>
          <br />
          <input
            type="number"
            id="scaling"
            placeholder="1.0"
            step="0.01"
            min="0"
            max="5"
          ></input>
        </p>
        <p>
          <label>Wall thickness (outside and inside):</label>
          <br />
          <input
            type="number"
            id="outside_thickness"
            placeholder="1.0"
            step="0.01"
            min="0"
            max="5"
          ></input>
          <input
            type="number"
            id="inside_thickness"
            placeholder="1.0"
            step="0.01"
            min="0"
            max="5"
          ></input>
        </p>
{/*
        <p>Click on a location on the map to select it (TO BE DONE)</p>
*/}
        <br />
        <br />
        <div className="row">
          <Link to="/verification/" className="btn btn-primary my-2" onChange={sendStatistics}>
            Continue
          </Link>
{/*          <Link to="/" className="btn btn-secondary my-2">
            Home
          </Link>*/}
        </div>
      </div>
    </Layout>
  );
};

export default Start;

export const Head = () => <Seo title="Start" />;
