//
// From https://github.com/Viglino/Map-georeferencer/
// Map-georeferencer is licenced under the French Opensource BSD like CeCILL-B FREE SOFTWARE LICENSE.
// (c) 2016 - Jean-Marc Viglino
//
var ol = OpenLayers;
if (!ol.transform) ol.transform = {};

/** Helmert transformation is a transformation method within a three-dimensional space. 
*	It is frequently used in geodesy to produce distortion-free transformations from one datum to another. 
*	It is composed of scaling o rotation o translation
*	Least squares is used to solve the problem of determining the parameters.
*	[X] = [sx] . [cos -sin] + [tx]
*	[Y]   [sy]   [sin  cos]   [ty]
*	
*	With the similarity option the scale is the same along both axis ie. sx = sy
*/
ol.transform.Helmert = function (options)
{	if (!options) options={};
	this.similarity = options.similarity;
	this.matrix = [1,0,0,0,1,0];
	this.hasControlPoints = false;
}

/** Calculate the helmert transform with control points.
* @return {Array.<ol.Coordinate>}: source coords 
* @return {Array.<ol.Coordinate>: projected coords
*/
ol.transform.Helmert.prototype.setControlPoints = function(xy, XY)
{	if (xy.length<2) 
	{	this.matrix = [1,0,0,0,1,0];
		this.hasControlPoints = false;
	}
	else
	{	if (this.similarity || xy.length<3) this.matrix = this._similarity ( xy, XY );
		else this.matrix = this._helmert ( xy, XY );
		this.hasControlPoints = true;
	}
	return this.hasControlPoints;
}

/** Get the rotation of the transform
* @return {Number}: angle
*/
ol.transform.Helmert.prototype.getRotation = function()
{	return this.a_;
}

/** Get the scale of the transform
* @return {ol.Coordinate}: scale along x and y axis
*/
ol.transform.Helmert.prototype.getScale = function()
{	return this.sc_
}

/** Get the rotation of the translation
* @return {ol.Coordinate}: translation
*/
ol.transform.Helmert.prototype.getTranslation = function()
{	return this.tr_;
}

/** Transform a point 
* @param {ol.Coordinate}: coordinate in the origin datum 
* @return {ol.Coordinate}: coordinate in the destination datum 
*/
ol.transform.Helmert.prototype.transform = function(xy)
{	var m = this.matrix;
	return [ m[0]*xy[0] + m[1]*xy[1] +m[2], m[3]*xy[0] + m[4]*xy[1] +m[5] ];
}

/** Revers transform of a point 
* @param {ol.Coordinate}: coordinate in the destination datum
* @return {ol.Coordinate}: coordinate in the origin datum
*/
ol.transform.Helmert.prototype.revers = function(xy)
{	var a = this.matrix[0];
	var b = this.matrix[1];
	var c = this.matrix[3];
	var d = this.matrix[4];
	var p = this.matrix[2];
	var q = this.matrix[5];
	return [
		(d*xy[0] - b*xy[1] +b*q - p*d) / (a*d-b*c),
		(-c*xy[0] + a*xy[1] + c*p - a*q) / (a*d-b*c),
	];
}

/**
Transformee de Helmert au moindre carre :
	Somme ( carre (a*xy + b - XY) ) minimale
	avec A de la forme :
	[a -b]
	[b  a]
**/
ol.transform.Helmert.prototype._similarity = function( xy, XY )
{	if ( !xy.length || xy.length != XY.length ) 
	{	console.log ("Helmert : Taille des tableaux de points incompatibles");
		return false; 
	}
	var i;					// Variable de boucle
	var n = XY.length;		// nb points de calage
	var a=1,b=0,p=0,q=0;

	// Barycentre
	var mxy = { x:0 , y:0 };
	var mXY = { x:0 , y:0 };
	for (i=0; i<n; i++)
	{	mxy.x += xy[i][0];
		mxy.y += xy[i][1];
		mXY.x += XY[i][0];
		mXY.y += XY[i][1];
	}
	mxy.x /= n;
	mxy.y /= n;
	mXY.x /= n;
	mXY.y /= n;
	
	// Ecart au barycentre
	var xy0 = [], XY0 = [];
	for (i=0; i<n; i++)
	{	xy0.push ({ x : xy[i][0] - mxy.x, y : xy[i][1] - mxy.y });
		XY0.push ({ x : XY[i][0] - mXY.x, y : XY[i][1] - mXY.y });
	}
	
	// Resolution
	var  SxX, SxY, SyY, SyX, Sx2, Sy2;
	SxX = SxY = SyY = SyX = Sx2 = Sy2 = 0;
	for (i=0; i<n; i++)
	{	SxX += xy0[i].x * XY0[i].x;
		SxY += xy0[i].x * XY0[i].y;
		SyY += xy0[i].y * XY0[i].y;
		SyX += xy0[i].y * XY0[i].x;
		Sx2 += xy0[i].x * xy0[i].x;
		Sy2 += xy0[i].y * xy0[i].y;
	}

	// Coefficients
	a = ( SxX + SyY ) / ( Sx2 + Sy2 );
	b = ( SxY - SyX ) / ( Sx2 + Sy2 );
	p = mXY.x - a * mxy.x + b * mxy.y;
	q = mXY.y - b * mxy.x - a * mxy.y;

	// la Solution
	this.matrix = [ a, -b, p, b, a, q ];

	var sc = Math.sqrt(a*a+b*b)
	this.a_ = Math.acos(a/sc);
	if (b>0) this.a_ *= -1;
	this.sc_ = [sc,sc];
	this.tr_ = [p,q];

	return this.matrix;
}


/**
Transformee de Helmert-Etendue au moindre carre :
	Somme ( carre (a*xy + b - XY) ) minimale
	avec A de la forme :
	[a -b][k 0]
	[b  a][0 h]
**/
ol.transform.Helmert.prototype._helmert = function (xy, XY, poids, tol)
{	if ( !xy.length || xy.length != XY.length ) 
	{	console.log ("Helmert : Taille des tableaux de points incompatibles");
		return false; 
	}
	var i;					// Variable de boucle
	var n = xy.length;		// nb points de calage
	// Creation de poids par defaut
	if (!poids) poids = [];
	if (poids.length == 0 || n != poids.iGetTaille()) 
	{	for (i=0; i<n; i++) poids.push(1.0); 
	}
	
	var a,b,k,h, tx, ty;
	if (!tol) tol = 0.0001;

	// Initialisation (sur une similitude)
	var affine = this._similarity( xy, XY);
	a = affine[0];
	b = -affine[1];
	k = h = Math.sqrt(a*a + b*b);
	a /= k;
	b /= k;
	tx = affine[2];
	ty = affine[5];

	// Barycentre
	var mxy = {x:0, y:0};
	var mXY = {x:0, y:0};
	for (i=0; i<n; i++)
	{	mxy.x += xy[i][0];
		mxy.y += xy[i][1];
		mXY.x += XY[i][0];
		mXY.y += XY[i][1];
	}
	mxy.x /= n;
	mxy.y /= n;
	mXY.x /= n;
	mXY.y /= n;

	// Ecart au barycentre
	var xy0 = [], XY0 = [];
	for (i=0; i<n; i++)
	{	xy0.push ({ x : xy[i][0] - mxy.x, y : xy[i][1] - mxy.y });
		XY0.push ({ x : XY[i][0] - mXY.x, y : XY[i][1] - mXY.y });
	}

	// Variables
	var Sx, Sy, Sxy, SxX, SxY, SyX, SyY;
	Sx=Sy=Sxy=SxX=SxY=SyX=SyY=0;
	for (i=0; i<n; i++)
	{	Sx  += xy0[i].x * xy0[i].x * poids[i];
		Sxy += xy0[i].x * xy0[i].y * poids[i];
		Sy  += xy0[i].y * xy0[i].y * poids[i];
		SxX += xy0[i].x * XY0[i].x * poids[i];
		SyX += xy0[i].y * XY0[i].x * poids[i];
		SxY += xy0[i].x * XY0[i].y * poids[i];
		SyY += xy0[i].y * XY0[i].y * poids[i];
	}
	
	// Iterations
	var	dk, dh, dt;
	var	A, B, C, D, E, F, G, H;
	var	da, db;
	var	div = 1e10;

	do 
	{	A = Sx;
		B = Sy;
		C = k*k*Sx + h*h*Sy;
		D = -h*Sxy;
		E =  k*Sxy;
		F =  a*SxX + b*SxY - k*Sx;
		G = -b*SyX + a*SyY - h*Sy;
		H = -k*b*SxX + k*a*SxY - h*a*SyX - h*b*SyY;

		// 
		dt = (A*B*H - B*D*F - A*E*G) / (A*B*C - B*D*D - A*E*E);
		dk = (F - D*dt) / A;
		dh = (G - E*dt) / A;

		// Probleme de divergence numerique
		if (Math.abs(dk) + Math.abs(dh) > div) break;

		// Nouvelle approximation
		da = a * Math.cos(dt) - b * Math.sin(dt);
		db = b * Math.cos(dt) + a * Math.sin(dt);
		a = da;
		b = db;
		k += dk;
		h += dh;

		div = Math.abs(dk) + Math.abs(dh);
	} while (Math.abs(dk) + Math.abs(dh) > tol);

	// Retour du repere barycentrique
	tx = mXY.x - a*k * mxy.x + b*h * mxy.y;
	ty = mXY.y - b*k * mxy.x - a*h * mxy.y;

	this.a_ = Math.acos(a);
	if (b>0) this.a_ *= -1;
	if (Math.abs(this.a_) < Math.PI/8)
	{	this.a_ = Math.asin(-b);
		if (a<0) this.a_ = Math.PI - this.a_;
	}
	this.sc_ = [k,h];
	this.tr_ = [tx,ty];

	// la Solution
	this.matrix = [];
	this.matrix[0] = a * k;
	this.matrix[1] = -b * h;
	this.matrix[2] = tx;
	this.matrix[3] = b * k;
	this.matrix[4] = a * h;
	this.matrix[5] = ty;
	return this.matrix;
}
