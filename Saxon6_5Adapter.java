//
//  Saxon6_5Adapter.java
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/19/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

import javax.xml.transform.TransformerFactory;

public class Saxon6_5Adapter extends AdapterBase {

	protected String getImplClassName() {
		return "com.icl.saxon.TransformerFactoryImpl";
	}
	
	protected void setVerboseListener(TransformerFactory factory, TraceListenerImpl tracer) {
		factory.setAttribute(com.icl.saxon.FeatureKeys.TRACE_LISTENER, tracer);
	}

}
