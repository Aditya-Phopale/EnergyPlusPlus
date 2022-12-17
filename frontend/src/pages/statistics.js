import * as React from "react";
import { Link } from "gatsby";
import { useState, useEffect } from "react";
import { StaticImage } from "gatsby-plugin-image";

import Layout from "../components/layout";
import { Seo } from "../components/seo";

//https://stackoverflow.com/questions/38049966/get-image-preview-before-uploading-in-react+
export const Start = () => {
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
            id="outside"
            placeholder="1.0"
            step="0.01"
            min="0"
            max="5"
          ></input>
          <input
            type="number"
            id="inside"
            placeholder="1.0"
            step="0.01"
            min="0"
            max="5"
          ></input>
        </p>
        <br />
        <br />
        <div className="row">
          <Link to="/verification/" className="btn btn-primary my-2">
            Recognize my rooms
          </Link>
          <Link to="/" className="btn btn-secondary my-2">
            Home
          </Link>
        </div>
      </div>
    </Layout>
  );
};

export default Start;

export const Head = () => <Seo title="Start" />;
