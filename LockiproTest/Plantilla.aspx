﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Plantilla.aspx.cs" Inherits="LockiproTest.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>PDF Viewer</title>
    <script src="https://mozilla.github.io/pdf.js/build/pdf.js"></script>
    <script src="https://unpkg.com/konva@7.0.3/konva.min.js"></script>

    <style>
        * {
            font-family: 'Averta ☞';
        }

        body {
            background-color: rgba(2, 5, 24, 255);
        }

            body * {
                color: rgba(255, 255, 255, 255);
            }

        input, select {
            background-color: transparent;
            color: rgba(255, 255, 255, 255);
            border-radius: 5px;
            padding: 5px;
            margin: 5px;
        }

        button, #btnEnviar {
            background-color: transparent;
            color: rgba(255, 255, 255, 255);
            border-width: 1px;
            border-color: white;
            border-radius: 25px;
            padding: 10px;
            font-weight: bold;
        }

            button:hover, #btnEnviar:hover {
                background-color: orchid;
                color: rgba(0, 0, 0, 255);
                border-color: black;
                cursor: pointer;
            }

        select:hover {
            cursor: pointer;
        }

        .inputNumber {
            width: 40px;
        }

        .inputFormProperties {
            background-color: rgba(37, 37, 45, 255);
        }

        .linePink {
            color: orchid;
        }

        #divToolbarLeft {
            grid-area: divToolbarLeft;
        }

        #divPdf {
            grid-area: divPdf;
        }

        #divToolbarRight {
            grid-area: divToolbarRight;
            width: 500px;
            margin-left: 700px;
            background-color: rgba(43, 45, 58, 255);
            padding: 25px;
        }

        #Container {
            display: grid;
            grid-template-areas: 'divToolbarLeft divPdf divToolbarRigh';
        }

        #divParentSigners {
            height: 500px;
            padding: 20px;
            overflow-y: scroll;
            background-color: rgba(53, 55, 68, 255);
        }
    </style>
</head>
<body>
    <h1 style="margin-left: 50px;">locki.pro Test</h1>
    <input type="submit" id="btnEnviar" value="Enviar" style="margin-left: 50px;"/>
    <div>
    </div>
    <div id="Container">
        <div id="divToolbarLeft">
        </div>

        <div id="divPdf" style="position: relative;">
            <div id="divCanvas" style="position: absolute; top: 0; left: 0;">
                <canvas id="the-canvas"></canvas>
            </div>
            <div id="containerKonva" style="position: absolute; top: 0; left: 0; z-index: 10;"></div>
        </div>

        <div id="divToolbarRight">
            <label>Pagina:</label>
            <select class="pages" name="pages" id="pagesSelect"></select>
            <div>
                <h2>Numero de firmantes</h2>
                <input type="number" max="10" min="1" value="1" id="numberSigners" class="inputNumber" />
                <button id="addSigners">Agregar Firmantes</button>
            </div>

            <div>
                <h2>Firmantes existentes</h2>
                Selecciona el firmante al que le quieres agregar un campo: 
                <select class="signers" name="signers" id="signers">
                    <option value="null">Nulo</option>
                </select>
            </div>

            <button id="addObject">Agregar campo para firma</button>
            <button id="addText">Agregar campo de texto</button>
            <button id="save">Guardar</button>
            <div>
                <input type="text" id="txtDelete" placeholder="Objeto seleccionado" disabled />
                <button id="delete">Borrar</button>
            </div>
            <div id="parentReference">
                <h2>Campos existentes</h2>
                <div id="divReferenceToolbarLeft"></div>
            </div>
            <div id="divParentSigners">
                <div id="divReferenceSigners"></div>
            </div>
        </div>
    </div>
    <script>
        //parent class for objects draggable
        class ObjectDraggable {
            constructor(id, x, y, fill, draggable, page) {
                this.id = id;
                this.x = x;
                this.y = y;
                this.fill = fill;
                this.draggable = draggable;
                this.page = page;
            }
        }

        //children class for TextDraggable
        class TextDraggable extends ObjectDraggable {
            constructor(id, x, y, fill, draggable, page, text, fontSize, fontFamily, stroke) {
                super(id, x, y, fill, draggable, page);
                this.id = id;
                this.x = x;
                this.y = y;
                this.fill = fill;
                this.draggable = draggable;
                this.page = page;
                this.text = text;
                this.fontSize = fontSize;
                this.fontFamily = fontFamily;
                this.stroke = stroke;
            }

            CreateText() {
                var text = new Konva.Text({
                    id: this.id,
                    x: this.x,
                    y: this.y,
                    text: this.text,
                    fontSize: this.fontSize,
                    fontFamily: this.fontFamily,
                    fill: this.fil,
                    name: this.page,
                    draggable: this.draggable,
                    stroke: this.stroke,
                    strokeWidth: 1,
                });

                return text;
            }

            CreatePropertiesForm(signer) {
                //div for text ******************************************
                var divT = document.createElement('div');

                //content of divT
                var lblT = document.createTextNode('Nombre: ');
                divT.appendChild(lblT);

                var T = document.createElement('input');
                T.id = 't' + this.id;
                T.type = 'text';
                T.value = this.text;
                T.className = "inputFormProperties";
                divT.appendChild(T);

                //div for fontsize **************************************
                var divFS = document.createElement('div');

                //contetn of divFS
                var lblFS = document.createTextNode('Tamaño de letra: ');
                divFS.appendChild(lblFS);

                var FS = document.createElement('input');
                FS.id = 'fs' + this.id;
                FS.type = 'text';
                FS.value = this.fontSize;
                FS.className = "inputFormProperties";
                divFS.appendChild(FS);

                //div for font family **********************************
                var divFF = document.createElement('div');

                //content of divFF
                var lblFF = document.createTextNode('Fuente: ');
                divFF.appendChild(lblFF);

                var FF = document.createElement('select');
                FF.id = 'ff' + this.id;
                FF.className = "inputFormProperties";
                divFF.appendChild(FF);

                var FFCalibri = document.createElement('option');
                FFCalibri.text = this.fontFamily;
                FFCalibri.value = this.fontFamily;
                FF.add(FFCalibri);

                var FFArial = document.createElement('option');
                FFArial.text = 'Arial';
                FFArial.value = 'Arial';
                FF.add(FFArial);

                var FFSansSerif = document.createElement('option');
                FFSansSerif.text = 'Sans Serif';
                FFSansSerif.value = 'Sans Serif';
                FF.add(FFSansSerif);

                var FFHelvetica = document.createElement('option');
                FFHelvetica.text = 'Helvetica';
                FFHelvetica.value = 'Helvetica';
                FF.add(FFHelvetica);

                var FFGaramond = document.createElement('option');
                FFGaramond.text = 'Garamond';
                FFGaramond.value = 'Garamond';
                FF.add(FFGaramond);

                var FFBodoni = document.createElement('option');
                FFBodoni.text = 'Bodoni';
                FFBodoni.value = 'Bodoni';
                FF.add(FFBodoni);

                var FFRockwell = document.createElement('option');
                FFRockwell.text = 'Rockwell';
                FFRockwell.value = 'Rockwell';
                FF.add(FFRockwell);

                var FFTahoma = document.createElement('option');
                FFTahoma.text = 'Tahoma';
                FFTahoma.value = 'Tahoma';
                FF.add(FFTahoma);

                var FFTimesNewRoman = document.createElement('option');
                FFTimesNewRoman.text = 'Times New Roman';
                FFTimesNewRoman.value = 'Times New Roman';
                FF.add(FFTimesNewRoman);

                var FFVerdana = document.createElement('option');
                FFVerdana.text = 'Verdana';
                FFVerdana.value = 'Verdana';
                FF.add(FFVerdana);

                //div for font color ************************************
                //var divFC = document.createElement('div');

                //content of divFC
                //var lblFC = document.createTextNode('Color: ');
                //divFC.appendChild(lblFC);

                //var FC = document.createElement('input');
                //FC.id = 'fc' + this.id;
                //FC.type = 'color';
                //FC.value = this.fill;
                //divFC.appendChild(FC);

                //div for position x ************************************
                var divX = document.createElement('div');

                //content of divX
                var lblX = document.createTextNode('Posición x: ');
                divX.appendChild(lblX);

                var X = document.createElement('input');
                X.id = 'x' + this.id;
                X.type = 'text';
                X.value = this.x;
                X.className = "inputFormProperties";
                divX.appendChild(X);

                //div for position y ***************************************
                var divY = document.createElement('div');

                //content of divY
                var lblY = document.createTextNode('Posición y: ');
                divY.appendChild(lblY);

                var Y = document.createElement('input');
                Y.id = 'y' + this.id;
                Y.type = 'text';
                Y.value = this.y;
                Y.className = "inputFormProperties";
                divY.appendChild(Y);

                //div for rotation *****************************************
                //var divR = document.createElement('div');

                //content of divR
                //var lblR = document.createTextNode('Rotación: ');
                //divR.appendChild(lblR);

                //var R = document.createElement('input');
                //R.id = 'r' + this.id;
                //R.type = 'text';
                //R.value = this.rotation;
                //divR.appendChild(R);

                //div for width *****************************************
                var divW = document.createElement('div');

                //content of divW
                var lblW = document.createTextNode('Ancho: ');
                divW.appendChild(lblW);

                var W = document.createElement('input');
                W.id = 'w' + this.id;
                W.type = 'text';
                W.value = this.width;
                W.className = "inputFormProperties";
                divW.appendChild(W);

                //div for height *****************************************
                var divH = document.createElement('div');

                //content of divH
                var lblH = document.createTextNode('Alto: ');
                divH.appendChild(lblH);

                var H = document.createElement('input');
                H.id = 'h' + this.id;
                H.type = 'text';
                H.value = this.height;
                H.className = "inputFormProperties";
                divH.appendChild(H);

                var line = document.createElement('hr');

                //div main
                var divMain = document.createElement('div');
                divMain.id = 'divMain' + this.id;
                divMain.appendChild(divT);
                divMain.appendChild(divFS);
                divMain.appendChild(divFF);
                //divMain.appendChild(divFC);
                divMain.appendChild(divX);
                divMain.appendChild(divY);
                //divMain.appendChild(divR);
                divMain.appendChild(divW);
                divMain.appendChild(divH);
                divMain.appendChild(line);

                //parent for divMain
                var parent = document.createElement('div');
                parent.appendChild(divMain);

                var parentDiv = document.getElementById(signer);
                parentDiv.appendChild(parent);
            }

            UpdatePropertiesForm() {
                var i;
                for (i = 0; i < textsDragg.length; i++) {
                    if (textsDragg[i].name() == currentPage) {
                        var T = document.getElementById('t' + textsDragg[i].id());
                        T.addEventListener('change', ChangePropertiesText);

                        var FS = document.getElementById('fs' + textsDragg[i].id());
                        FS.addEventListener('change', ChangePropertiesText);

                        var FF = document.getElementById('ff' + textsDragg[i].id());
                        FF.addEventListener('change', ChangePropertiesText);

                        //var FC = document.getElementById('fc' + textsDragg[i].id());
                        //FC.addEventListener('change', ChangePropertiesText);

                        var X = document.getElementById('x' + textsDragg[i].id());
                        X.value = textsDragg[i].x();
                        X.addEventListener('change', ChangePropertiesText);

                        var Y = document.getElementById('y' + textsDragg[i].id());
                        Y.value = textsDragg[i].y();
                        Y.addEventListener('change', ChangePropertiesText);

                        //var R = document.getElementById('r' + textsDragg[i].id());
                        //R.value = textsDragg[i].rotation();
                        //R.addEventListener('change', ChangePropertiesText);

                        var W = document.getElementById('w' + textsDragg[i].id());
                        W.value = textsDragg[i].scaleX() * textsDragg[i].width();
                        W.addEventListener('change', ChangePropertiesText);

                        var H = document.getElementById('h' + textsDragg[i].id());
                        H.value = textsDragg[i].scaleY() * textsDragg[i].height();
                        H.addEventListener('change', ChangePropertiesText);
                    }
                }
            }
        }

        var idDivSigner = 1;
        //children class for RectDraggable
        class RectDraggable extends ObjectDraggable {
            constructor(id, x, y, width, height, fill, draggable, page, stroke) {
                super(id, x, y, fill, draggable, page);
                this.id = id;
                this.x = x;
                this.y = y;
                this.width = width;
                this.height = height;
                this.fill = fill;
                this.draggable = draggable;
                this.page = page;
                this.stroke = stroke;
            }

            CreateRect() {
                var rectangle = new Konva.Rect({
                    id: this.id,
                    x: this.x,
                    y: this.y,
                    width: this.width,
                    height: this.height,
                    fill: this.fill,
                    name: this.page,
                    stroke: this.stroke,
                    draggable: this.draggable,
                });

                return rectangle;
            }

            CreatePropertiesForm(signer) {
                //div for position x ************************************
                var divX = document.createElement('div');

                //content of divX
                var lblX = document.createTextNode('Posición x: ');
                divX.appendChild(lblX);

                var X = document.createElement('input');
                X.id = 'x' + this.id;
                X.type = 'text';
                X.value = this.x;
                X.className = "inputFormProperties";
                divX.appendChild(X);

                //div for position y ***************************************
                var divY = document.createElement('div');

                //content of divY
                var lblY = document.createTextNode('Posición y: ');
                divY.appendChild(lblY);

                var Y = document.createElement('input');
                Y.id = 'y' + this.id;
                Y.type = 'text';
                Y.value = this.y;
                Y.className = "inputFormProperties";
                divY.appendChild(Y);

                //div for rotation *****************************************
                //var divR = document.createElement('div');

                //content of divR
                //var lblR = document.createTextNode('Rotación: ');
                //divR.appendChild(lblR);

                //var R = document.createElement('input');
                //R.id = 'r' + this.id;
                //R.type = 'text';
                //R.value = 0;
                //divR.appendChild(R);

                //div for width *****************************************
                var divW = document.createElement('div');

                //content of divW
                var lblW = document.createTextNode('Ancho: ');
                divW.appendChild(lblW);

                var W = document.createElement('input');
                W.id = 'w' + this.id;
                W.type = 'text';
                W.value = this.width;
                W.className = "inputFormProperties";
                divW.appendChild(W);

                //div for height *****************************************
                var divH = document.createElement('div');

                //content of divH
                var lblH = document.createTextNode('Alto: ');
                divH.appendChild(lblH);

                var H = document.createElement('input');
                H.id = 'h' + this.id;
                H.type = 'text';
                H.value = this.height;
                H.className = "inputFormProperties";
                divH.appendChild(H);

                var line = document.createElement('hr');

                //div main
                var divMain = document.createElement('div');
                divMain.id = 'divMain' + this.id;
                divMain.appendChild(divX);
                divMain.appendChild(divY);
                //divMain.appendChild(divR);
                divMain.appendChild(divW);
                divMain.appendChild(divH);
                divMain.appendChild(line);

                //parent for divMain
                var parent = document.createElement('div');
                parent.appendChild(divMain);

                var parentDiv = document.getElementById(signer);
                parentDiv.appendChild(parent);
            }

            CreatePropertiesForm() {
                //div for position x ************************************
                var divX = document.createElement('div');

                //content of divX
                var lblX = document.createTextNode('Posición x: ');
                divX.appendChild(lblX);

                var X = document.createElement('input');
                X.id = 'x' + this.id;
                X.type = 'text';
                X.value = this.x;
                X.className = "inputFormProperties";
                divX.appendChild(X);

                //div for position y ***************************************
                var divY = document.createElement('div');

                //content of divY
                var lblY = document.createTextNode('Posición y: ');
                divY.appendChild(lblY);

                var Y = document.createElement('input');
                Y.id = 'y' + this.id;
                Y.type = 'text';
                Y.value = this.y;
                Y.className = "inputFormProperties";
                divY.appendChild(Y);

                //div for rotation *****************************************
                //var divR = document.createElement('div');

                //content of divR
                //var lblR = document.createTextNode('Rotación: ');
                //divR.appendChild(lblR);

                //var R = document.createElement('input');
                //R.id = 'r' + this.id;
                //R.type = 'text';
                //R.value = 0;
                //divR.appendChild(R);

                //div for width *****************************************
                var divW = document.createElement('div');

                //content of divW
                var lblW = document.createTextNode('Ancho: ');
                divW.appendChild(lblW);

                var W = document.createElement('input');
                W.id = 'w' + this.id;
                W.type = 'text';
                W.value = this.width;
                W.className = "inputFormProperties";
                divW.appendChild(W);

                //div for height *****************************************
                var divH = document.createElement('div');

                //content of divH
                var lblH = document.createTextNode('Alto: ');
                divH.appendChild(lblH);

                var H = document.createElement('input');
                H.id = 'h' + this.id;
                H.type = 'text';
                H.value = this.height;
                H.className = "inputFormProperties";
                divH.appendChild(H);

                var line = document.createElement('hr');

                //div main
                var divMain = document.createElement('div');
                divMain.id = 'divMain' + this.id;
                divMain.appendChild(divX);
                divMain.appendChild(divY);
                //divMain.appendChild(divR);
                divMain.appendChild(divW);
                divMain.appendChild(divH);
                divMain.appendChild(line);

                //parent for divMain
                var parent = document.createElement('div');
                parent.appendChild(divMain);

                var parentDiv = document.getElementById('divReferenceSigners');
                parentDiv.appendChild(parent);
            }

            UpdatePropertiesForm() {
                var i;
                for (i = 0; i < objectsDragg.length; i++) {
                    if (objectsDragg[i].name() == currentPage) {
                        var X = document.getElementById('x' + objectsDragg[i].id());
                        X.value = objectsDragg[i].x();
                        X.addEventListener('change', ChangePropertiesRectangle);

                        var Y = document.getElementById('y' + objectsDragg[i].id());
                        Y.value = objectsDragg[i].y();
                        Y.addEventListener('change', ChangePropertiesRectangle);

                        //var R = document.getElementById('r' + objectsDragg[i].id());
                        //R.value = objectsDragg[i].rotation();
                        //R.addEventListener('change', ChangePropertiesRectangle);

                        var W = document.getElementById('w' + objectsDragg[i].id());
                        W.value = objectsDragg[i].scaleX() * objectsDragg[i].width();
                        W.addEventListener('change', ChangePropertiesRectangle);

                        var H = document.getElementById('h' + objectsDragg[i].id());
                        H.value = objectsDragg[i].scaleY() * objectsDragg[i].height();
                        H.addEventListener('change', ChangePropertiesRectangle);
                    }
                }
            }
        }

        // If absolute URL from the remote server is provided, configure the CORS
        // header on that server.
        var url = 'https://raw.githubusercontent.com/mozilla/pdf.js/ba2edeae/web/compressed.tracemonkey-pldi-09.pdf';

        // Loaded via <script> tag, create shortcut to access PDF.js exports.
        var pdfjsLib = window['pdfjs-dist/build/pdf'];

        // The workerSrc property shall be specified.
        pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://mozilla.github.io/pdf.js/build/pdf.worker.js';

        //array of objects draggeables
        var objectsDragg = [];
        var textsDragg = [];

        //properties for pdf.js
        var pdfDoc = null;
        var scale = 1.3;
        var pageNum = 1;
        var pagesSelect = document.getElementById('pagesSelect');
        var currentPage = 0;
        var ancientPage = 0;
        var existingSigners = document.getElementById('signers');
        var canvas = document.getElementById('the-canvas');
        var context = canvas.getContext('2d');

        //properties for objects draggeables
        var width = window.innerWidth;
        var height = window.innerHeight;

        //create stage for konvas
        var stage = new Konva.Stage({
            container: 'containerKonva',
            width: width,
            height: height,
        });

        //create layer
        var layer = new Konva.Layer();
        stage.add(layer);

        //functino for get the pdf
        pdfjsLib.getDocument(url).promise.then(function (pdfDoc_) {
            pdfDoc = pdfDoc_;

            RenderPage(pageNum);

            var i;
            for (i = 1; i <= pdfDoc.numPages; i++) {
                var option = document.createElement('option');
                option.text = i;
                option.value = i;
                pagesSelect.add(option);
            }

            currentPage = pagesSelect.value;
        });

        //function for render page in the canvas
        function RenderPage(num) {
            // Using promise to fetch the page
            pdfDoc.getPage(num).then(function (page) {
                var viewport = page.getViewport({ scale: scale });
                //set canvas canvas
                canvas.height = viewport.height;
                canvas.width = viewport.width;

                stage.width(viewport.width);
                stage.height(viewport.height);

                var divpdf = document.getElementById('divPdf');
                divpdf.width = viewport.width;
                divpdf.height = viewport.height;

                //render pdf page into canvas context
                var renderContext = {
                    canvasContext: context,
                    viewport: viewport
                }
                var renderTask = page.render(renderContext);
                renderTask.promise.then(function () {
                    console.log('Page rendered');
                });
            });
        }

        //function for change page with select
        function ChangePage() {
            ancientPage = currentPage;
            currentPage = pagesSelect.value;

            //save datas
            Save();

            //remove objects draggables
            layer.removeChildren();

            //remove properties form
            CleanPropertiesForm();

            //render the next page
            RenderPage(parseInt(currentPage));
            console.log('pagina ' + currentPage);

            //add existing object
            AddExistingObjects(currentPage);

            //call method draw from layer for if don't exist an objects update the layer
            layer.draw();
        }
        //assign the function ChangePage to the select
        pagesSelect.addEventListener('change', ChangePage);

        //function for add existing objects
        function AddExistingObjects(page) {
            //add exisitng rects
            for (var i = 0; i < objectsDragg.length; i++) {
                if (objectsDragg[i].name() == page) {
                    var rectangle = new RectDraggable(objectsDragg[i].id(), objectsDragg[i].x(), objectsDragg[i].y(), objectsDragg[i].width(), objectsDragg[i].height(), objectsDragg[i].fill(), objectsDragg[i].draggable(), objectsDragg[i].name(), objectsDragg[i].stroke());
                    rect = rectangle.CreateRect();
                    layer.add(rect);

                    //change the object for made the match with the properties form
                    objectsDragg[i] = rect;

                    //create new transformer
                    var transformer = new Konva.Transformer();
                    transformer.rotateEnabled(false);
                    layer.add(transformer);
                    transformer.nodes([rect]);
                    layer.draw();


                    rect.on('transformstart', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                        rectangle.UpdatePropertiesForm();
                        console.log('transform start');
                    });

                    rect.on('dragmove', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                        rectangle.UpdatePropertiesForm();
                        console.log('dragmove')
                    });

                    rect.on('transform', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                        rectangle.UpdatePropertiesForm();
                        console.log('transform');
                    });

                    rect.on('transformend', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                        rectangle.UpdatePropertiesForm();
                        console.log('transform end');
                    });

                    rect.on('mouseover', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                        document.body.style.cursor = 'pointer';
                    });

                    rect.on('mouseout', function () {
                        document.body.style.cursor = 'default';
                    });

                    rect.on('click', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                    });

                    rectangle.CreatePropertiesForm(GetSigner(rect.stroke()));
                }
            }

            //add existing texts
            for (var j = 0; j < textsDragg.length; j++) {
                if (textsDragg[j].name() == page) {
                    //create the Konva.Text
                    var textDraggable = new TextDraggable(textsDragg[j].id(), textsDragg[j].x(), textsDragg[j].y(), textsDragg[j].fill(), textsDragg[j].draggable(), textsDragg[j].name(), textsDragg[j].text(), textsDragg[j].fontSize(), textsDragg[j].fontFamily(), textsDragg[j].stroke());
                    text = textDraggable.CreateText();
                    layer.add(text);

                    //change the object for made the match with the properties form
                    textsDragg[j] = text;

                    //create new transformer
                    var transformer = new Konva.Transformer();
                    transformer.rotateEnabled(false);
                    layer.add(transformer);
                    transformer.nodes([text]);
                    layer.draw();

                    text.on('transformstart', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                        textDraggable.UpdatePropertiesForm();
                        console.log('transform start');
                    });

                    text.on('dragmove', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                        textDraggable.UpdatePropertiesForm();
                        console.log('dragmove')
                    });
                    text.on('transform', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                        textDraggable.UpdatePropertiesForm();
                        console.log('transform');
                    });

                    text.on('transformend', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                        textDraggable.UpdatePropertiesForm();
                        console.log('transform end');
                    });

                    text.on('mouseover', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                        document.body.style.cursor = 'pointer';
                    });

                    text.on('mouseout', function () {
                        document.body.style.cursor = 'default';
                    });

                    text.on('click', function (e) {
                        document.getElementById('txtDelete').value = e.target.id();
                    });

                    textDraggable.CreatePropertiesForm(GetSigner(text.stroke()));
                }
            }
        }

        //clean all properties form
        function CleanPropertiesForm() {
            for (var i = 0; i <= objectsDragg.length; i++) {
                if (document.getElementById('divMainfirma' + (i + 1)) != null) {
                    var parentDivMain = document.getElementById('divMainfirma' + (i + 1)).parentNode;
                    parentDivMain.innerHTML = '';
                }
            }

            for (var i = 0; i <= textsDragg.length; i++) {
                if (document.getElementById('divMaintext' + (i + 1)) != null) {
                    var parentDivMain = document.getElementById('divMaintext' + (i + 1)).parentNode;
                    parentDivMain.innerHTML = '';
                }
            }
        }

        //clean specific property form
        function CleanSpecificPropertyForm(idObject) {
            var parentDivMain = document.getElementById('divMain' + idObject).parentNode;
            parentDivMain.innerHTML = '';
        }

        //function for add a text draggeable
        var idTextDraggeable = 1;
        var text = null;

        function AddTextDraggable() {
            if (existingSigners.value == 'null') {
                alert('Primero selecciona a que firmante le quieres agregar un campo de texto');
            }
            else {
                var stroke = GetColorObject();

                //create the Konva.Text
                var textDraggable = new TextDraggable('text' + idTextDraggeable, 10, 15, 'black', true, currentPage, 'Lorem ipsum', 30, 'Calibri', stroke);

                text = textDraggable.CreateText();

                layer.add(text);
                textsDragg.push(text);

                //create new transformer
                var transformer = new Konva.Transformer();
                transformer.rotateEnabled(false);
                layer.add(transformer);
                transformer.nodes([text]);
                layer.draw();

                text.on('transformstart', function (e) {
                    document.getElementById('txtDelete').value = e.target.id();
                    textDraggable.UpdatePropertiesForm();
                    console.log('transform start');
                });

                text.on('dragmove', function (e) {
                    document.getElementById('txtDelete').value = e.target.id();
                    textDraggable.UpdatePropertiesForm();
                    console.log('dragmove')
                });
                text.on('transform', function (e) {
                    document.getElementById('txtDelete').value = e.target.id();
                    textDraggable.UpdatePropertiesForm();
                    console.log('transform');
                });

                text.on('transformend', function (e) {
                    document.getElementById('txtDelete').value = e.target.id();
                    textDraggable.UpdatePropertiesForm();
                    console.log('transform end');
                });

                text.on('mouseover', function (e) {
                    document.getElementById('txtDelete').value = e.target.id();
                    document.body.style.cursor = 'pointer';
                });

                text.on('mouseout', function () {
                    document.body.style.cursor = 'default';
                });

                text.on('click', function (e) {
                    document.getElementById('txtDelete').value = e.target.id();
                });

                textDraggable.CreatePropertiesForm(existingSigners.value);
                idTextDraggeable++;
            }
        }
        document.getElementById('addText').addEventListener('click', AddTextDraggable);

        //function for set datas of text draggable
        function ChangePropertiesText() {
            var i;
            for (i = 0; i < textsDragg.length; i++) {
                var T = document.getElementById('ttext' + (i + 1));
                textsDragg[i].text(T.value);

                var FS = document.getElementById('fstext' + (i + 1));
                textsDragg[i].fontSize(parseInt(FS.value));

                var FF = document.getElementById('fftext' + (i + 1));
                textsDragg[i].fontFamily(FF.value);
                console.log(textsDragg[i].fontFamily());

                //var FC = document.getElementById('fctext' + (i + 1));
                //textsDragg[i].fill(FC.value);

                var X = document.getElementById('xtext' + (i + 1));
                textsDragg[i].x(parseInt(X.value));

                var Y = document.getElementById('ytext' + (i + 1));
                textsDragg[i].y(parseInt(Y.value));

                //var R = document.getElementById('rtext' + (i + 1));
                //textsDragg[i].rotation(parseInt(R.value));

                var W = document.getElementById('wtext' + (i + 1));
                textsDragg[i].width(parseInt(W.value));

                var H = document.getElementById('htext' + (i + 1));
                textsDragg[i].height(parseInt(H.value));

                layer.draw();
            }
        }

        //function for add a objects draggeables
        var idRectDragg = 1;
        var rect = null;

        function AddRectDraggeable() {
            if (existingSigners.value == 'null') {
                alert('Primero selecciona a que firmante le quieres agregar un campo para firma');
            }
            else {
                var stroke = GetColorObject();

                var rectangle = new RectDraggable('firma' + idRectDragg, 160, 60, 100, 90, 'white', true, currentPage, stroke);
                rect = rectangle.CreateRect();
                layer.add(rect);

                //create new transformer
                var transformer = new Konva.Transformer();
                transformer.rotateEnabled(false);

                layer.add(transformer);
                transformer.nodes([rect]);
                layer.draw();

                objectsDragg.push(rect);
                idRectDragg++;

                var i;
                for (i = 0; i < objectsDragg.length; i++) {
                    if (objectsDragg[i].id == rect.id) {
                        rect.on('transformstart', function (e) {
                            document.getElementById('txtDelete').value = e.target.id();
                            rectangle.UpdatePropertiesForm();
                            console.log('transform start');
                        });

                        rect.on('dragmove', function (e) {
                            document.getElementById('txtDelete').value = e.target.id();
                            rectangle.UpdatePropertiesForm();
                            console.log('dragmove')
                        });
                        rect.on('transform', function (e) {
                            document.getElementById('txtDelete').value = e.target.id();
                            rectangle.UpdatePropertiesForm();
                            console.log('transform');
                        });

                        rect.on('transformend', function (e) {
                            document.getElementById('txtDelete').value = e.target.id();
                            rectangle.UpdatePropertiesForm();
                            console.log('transform end');
                        });

                        rect.on('mouseover', function (e) {
                            document.getElementById('txtDelete').value = e.target.id();
                            document.body.style.cursor = 'pointer';
                        });

                        rect.on('mouseout', function () {
                            document.body.style.cursor = 'default';
                        });

                        rect.on('click', function (e) {
                            document.getElementById('txtDelete').value = e.target.id();
                        });
                    }
                }

                rectangle.CreatePropertiesForm(existingSigners.value);
            }
        }
        document.getElementById('addObject').addEventListener('click', AddRectDraggeable);

        //function for set datas of object draggeable
        function ChangePropertiesRectangle() {
            var i;
            for (i = 0; i < objectsDragg.length; i++) {
                var X = document.getElementById('x' + objectsDragg[i].id());
                objectsDragg[i].x(parseInt(X.value));

                var Y = document.getElementById('y' + objectsDragg[i].id());
                objectsDragg[i].y(parseInt(Y.value));

                //var R = document.getElementById('r' + objectsDragg[i].id());
                //objectsDragg[i].rotation(parseInt(R.value));

                var W = document.getElementById('w' + objectsDragg[i].id());
                objectsDragg[i].width(parseInt(W.value));

                var H = document.getElementById('h' + objectsDragg[i].id());
                objectsDragg[i].height(parseInt(H.value));

                //var ID = document.getElementById('id' + objectsDragg[i].id());
                //objectsDragg[i].id(ID.value);

                layer.draw();

                Save();
            }
        }

        //function for get color for objects draggable
        function GetColorObject() {
            var stroke;
            switch (document.getElementById('signers').value) {
                case 'signer1':
                    stroke = 'black';
                    break;

                case 'signer2':
                    stroke = 'yellow';
                    break;

                case 'signer3':
                    stroke = 'red';
                    break;

                case 'signer4':
                    stroke = 'blue';
                    break;

                case 'signer5':
                    stroke = 'gray';
                    break;

                case 'signer6':
                    stroke = 'orange';
                    break;

                case 'signer7':
                    stroke = 'pink';
                    break;

                case 'signer8':
                    stroke = 'purple';
                    break;

                case 'signer9':
                    stroke = 'green';
                    break;

                case 'signer10':
                    stroke = 'brown';
                    break;
            }

            return stroke;
        }

        //functino for get the signer of the object
        function GetSigner(stroke) {
            var signer;
            switch (stroke) {
                case 'black':
                    signer = 'signer1';
                    break;

                case 'yellow':
                    signer = 'signer2';
                    break;

                case 'red':
                    signer = 'signer3';
                    break;

                case 'blue':
                    signer = 'signer4';
                    break;

                case 'gray':
                    signer = 'signer5';
                    break;

                case 'orange':
                    signer = 'signer6';
                    break;

                case 'pink':
                    signer = 'signer7';
                    break;

                case 'purple':
                    signer = 'signer8';
                    break;

                case 'green':
                    signer = 'signer9';
                    break;

                case 'brown':
                    signer = 'signer10';
                    break;
            }

            return signer;
        }

        //function for adde tools for signers
        function AddSigner() {
            var numberSigners = document.getElementById('numberSigners').value;
            var howManySigner = existingSigners.length - 1;

            if (howManySigner == 10) {
                alert('Solo se permite agregar como máximo 10 firmantes.');
            }
            else {
                if (howManySigner > 0) {
                    for (var i = 0; i < numberSigners; i++) {
                        var option = document.createElement('option');
                        option.text = 'Firmante' + (i + howManySigner);
                        option.value = 'signer' + (i + howManySigner);
                        existingSigners.add(option);

                        //line
                        var line = document.createElement('hr');
                        line.color = 'pink';
                        line.className = 'linePink';

                        //div title
                        var divTitle = document.createElement('div');

                        var signer = document.createTextNode('Firmante ' + (i + howManySigner));
                        divTitle.appendChild(signer);

                        //create div main
                        var divMain = document.createElement('div');
                        divMain.id = 'signer' + (i + howManySigner);
                        divMain.appendChild(line);
                        divMain.appendChild(divTitle);

                        //insert div main
                        var parentDiv = document.getElementById('divReferenceSigners').parentNode;
                        var referenceDiv = document.getElementById('divReferenceSigners');
                        parentDiv.insertBefore(divMain, referenceDiv);
                    }
                }
                else {
                    for (var i = 0; i < numberSigners; i++) {
                        var option = document.createElement('option');
                        option.text = 'Firmante' + (i + 1);
                        option.value = 'signer' + (i + 1);
                        existingSigners.add(option);

                        //line
                        var line = document.createElement('hr');
                        line.color = 'pink';
                        line.className = 'linePink';

                        //div title
                        var divTitle = document.createElement('div');

                        var signer = document.createTextNode('Firmante ' + (i + 1));
                        divTitle.appendChild(signer);

                        //create div main
                        var divMain = document.createElement('div');
                        divMain.id = 'signer' + (i + 1);
                        divMain.appendChild(line);
                        divMain.appendChild(divTitle);

                        //insert div main
                        var parentDiv = document.getElementById('divReferenceSigners').parentNode;
                        var referenceDiv = document.getElementById('divReferenceSigners');
                        parentDiv.insertBefore(divMain, referenceDiv);
                    }
                }
            }
        }
        document.getElementById('addSigners').addEventListener('click', AddSigner);

        //function for save the datas of objects
        function Save() {
            var i;
            for (i = 0; i < objectsDragg.length; i++) {
                if (objectsDragg[i].id() == 'firma' + (i + 1) && objectsDragg[i].name() == ancientPage) {
                    var X = document.getElementById('x' + objectsDragg[i].id());
                    objectsDragg[i].x(parseInt(X.value));

                    var Y = document.getElementById('y' + objectsDragg[i].id());
                    objectsDragg[i].y(parseInt(Y.value));

                    //var R = document.getElementById('r' + objectsDragg[i].id());
                    //objectsDragg[i].rotation(parseInt(R.value));

                    var W = document.getElementById('w' + objectsDragg[i].id());
                    objectsDragg[i].width(parseInt(W.value));

                    var H = document.getElementById('h' + objectsDragg[i].id());
                    objectsDragg[i].height(parseInt(H.value));

                    console.log('Se guardaron los datos de ' + objectsDragg[i].id());
                }
            }

            var j;
            for (j = 0; j < textsDragg.length; j++) {
                if (textsDragg[j].id() == 'text' + (j + 1) && textsDragg[j].name() == ancientPage) {
                    var T = document.getElementById('ttext' + (j + 1));
                    textsDragg[j].text(T.value);

                    var FS = document.getElementById('fstext' + (j + 1));
                    textsDragg[j].fontSize(parseInt(FS.value));

                    var FF = document.getElementById('fftext' + (j + 1));
                    textsDragg[j].fontFamily(FF.value);
                    console.log(textsDragg[j].fontFamily());

                    //var FC = document.getElementById('fctext' + (j + 1));
                    //textsDragg[j].fill(FC.value);

                    var X = document.getElementById('xtext' + (j + 1));
                    textsDragg[j].x(parseInt(X.value));

                    var Y = document.getElementById('ytext' + (j + 1));
                    textsDragg[j].y(parseInt(Y.value));

                    //var R = document.getElementById('rtext' + (j + 1));
                    //textsDragg[j].rotation(parseInt(R.value));

                    var W = document.getElementById('wtext' + (j + 1));
                    textsDragg[j].width(parseInt(W.value));

                    var H = document.getElementById('htext' + (j + 1));
                    textsDragg[j].height(parseInt(H.value));

                    console.log('Se guardaron los datos de ' + textsDragg[j].id());
                }
            }

            layer.draw();
        }
        document.getElementById('save').addEventListener('click', Save);

        //function for delete an object
        function Delete() {
            //delete rect
            for (var i = 0; i < objectsDragg.length; i++) {
                if (objectsDragg[i].id() == document.getElementById('txtDelete').value) {
                    var transformer = layer.find('Transformer').toArray();

                    for (var x = 0; x < transformer.length; x++) {
                        var nodes = transformer[x].nodes();

                        for (var y = 0; y < nodes.length; y++) {

                            if (nodes[y].id() == document.getElementById('txtDelete').value) {
                                //remove the object
                                nodes[y].remove();
                                //destroy the transform of the node
                                transformer[x].destroy();
                                //clean the properties form
                                CleanSpecificPropertyForm(objectsDragg[i].id());
                                //remove the object from the array
                                objectsDragg.splice(i, 1);
                                //update the layer
                                layer.draw();
                            }
                        }
                    }
                }
            }

            //delete text
            for (var j = 0; j < textsDragg.length; j++) {
                if (textsDragg[j].id() == document.getElementById('txtDelete').value) {
                    var transformer = layer.find('Transformer').toArray();

                    for (var x = 0; x < transformer.length; x++) {
                        var nodes = transformer[x].nodes();

                        for (var y = 0; y < nodes.length; y++) {

                            if (nodes[y].id() == document.getElementById('txtDelete').value) {
                                //remove the object
                                nodes[y].remove();
                                //destroy the transform of the node
                                transformer[x].destroy();
                                //clean the properties form
                                CleanSpecificPropertyForm(textsDragg[j].id());
                                //remove the object from the array
                                textsDragg.splice(j, 1);
                                //update the layer
                                layer.draw();
                            }
                        }
                    }
                }
            }
        }
        document.getElementById('delete').addEventListener('click', Delete);

        //function for send objects in JSON
        function Send() {
            var jsonRect = JSON.stringify(objectsDragg);
            var jsonText = JSON.stringify(textsDragg);

            var form = document.createElement('form');
            form.method = 'post';
            form.action = 'Firmar.aspx';

            var hiddenRect = document.createElement('input');
            hiddenRect.id = 'hiddenRect';
            hiddenRect.type = 'hidden';
            hiddenRect.value = jsonRect;
            form.appendChild(hiddenRect);

            var hiddenText = document.createElement('input');
            hiddenText.id = 'hiddenText';
            hiddenText.type = 'hidden';
            hiddenText.value = jsonText;
            form.appendChild(hiddenText);

            document.body.appendChild(form);
            form.submit();
        }
        document.getElementById('btnEnviar').addEventListener('click', Send);
    </script>
</body>
</html>
