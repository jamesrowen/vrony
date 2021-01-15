# vrony

![vrony screenshot](https://user-images.githubusercontent.com/1694056/104701062-f1cb9b80-56c9-11eb-8630-454eee269d8d.png)

A Processing sketch for making animated Voronoi diagram patterns.

Contains a UI for adjusting parameters manually and automating parameter changes over time.

More information and background can be found at <https://james.js.org/vrony>.

The Voronoi algorithm is supplied by the excellent [Mesh library](https://leebyron.com/mesh/) by [Lee Byron](https://leebyron.com/).

## to run

1. Install [Processing 3](https://processing.org/download/).
2. Download or clone this repository.
3. Find the `/lib/mesh` folder in this project and move it into Processing's libraries folder (on Mac the default location is `~/Documents/Processing/libraries`). If you have Processing open, quit and restart it.
4. Open any of the `.pde` files in this project in Processing to load the sketch.
5. Press play!

## controls

- Press `Space` to play or pause.
- Press `S` to show or hide the UI.
- In the control panel, click the buttons and click and drag the sliders.
- In the sequencer, click on a red line to add a control point. Click and drag a control point to move it up or down. Click on a control point to remove it. Click and drag the white bar at the top to view different parts of the timeline.
