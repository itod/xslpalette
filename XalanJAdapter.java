//
//  XalanJAdapter.java
//  XSLPalette
//
//  Created by Todd Ditchendorf on 11/25/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

import javax.xml.transform.TransformerFactory;

public class XalanJAdapter extends AdapterBase {

	protected String getImplClassName() {
		return "org.apache.xalan.processor.TransformerFactoryImpl";
	}

	protected void setVerboseListener(TransformerFactory factory, TraceListenerImpl tracer) {
		//factory.setAttribute(net.sf.saxon.FeatureKeys.TRACE_LISTENER, tracer);
	}
	
}
