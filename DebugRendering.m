//
//  DebugRendering.m
//  DrawBattlefield
//
//  Created by James Washburn on 5/18/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
#import "factions.h"
#import "chipmunk.h"
//#import "Primitives.h"
#import "CCDrawingPrimitives.h"
#import "cocos2d.h"
#import "OpenGL_Internal.h"
#include <stdlib.h>
#include <stdio.h>
//#include <math.h>

void drawCircleShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpCircleShape *circle = (cpCircleShape *)shape;
	cpVect c = cpvadd(body->p, cpvrotate(circle->c, body->rot));
	ccDrawCircle( ccp(c.x, c.y), circle->r, body->a, 15, YES);
}

void drawSegmentShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpSegmentShape *seg = (cpSegmentShape *)shape;
	cpVect a = cpvadd(body->p, cpvrotate(seg->a, body->rot));
	cpVect b = cpvadd(body->p, cpvrotate(seg->b, body->rot));
	
	ccDrawLine( ccp(a.x, a.y), ccp(b.x, b.y) );
}

void drawPolyShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpPolyShape *poly = (cpPolyShape *)shape;
	
	int num = poly->numVerts;
	cpVect *verts = poly->verts;
	
	CGPoint *vertices =  (CGPoint *)malloc( sizeof(CGPoint)*poly->numVerts);
	if( ! vertices )
		return;
	
	for(int i=0; i<num; i++){
		cpVect v = cpvadd(body->p, cpvrotate(verts[i], body->rot));
		vertices[i] = v;
	}
	ccDrawPoly( vertices, poly->numVerts, YES );
	
	free(vertices);
}


 void
drawObject(void *ptr, void *unused)
{
	cpShape *shape = (cpShape *)ptr;
	switch(shape->klass->type){
		case CP_CIRCLE_SHAPE:
			drawCircleShape(shape);
			break;
		case CP_SEGMENT_SHAPE:
			drawSegmentShape(shape);
			break;
		case CP_POLY_SHAPE:
			drawPolyShape(shape);
			break;
		default:
			printf("Bad enumeration in drawObject().\n");
	}
}

void drawCollisions(void *ptr, void *data)
{
	cpArbiter *arb = (cpArbiter *)ptr;
	for(int i=0; i<arb->numContacts; i++){
		cpVect v = arb->contacts[i].p;
		ccDrawPoint( ccp(v.x, v.y) );
	}
}


static void 
pickingFunc(cpShape *shape, void *data)
{
	drawObject(shape, NULL);
}
