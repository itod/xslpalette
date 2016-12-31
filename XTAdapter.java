//
//  XTAdapter.java
//  XSLPalette
//
//  Created by Todd Ditchendorf on 11/25/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

import javax.xml.transform.TransformerFactory;

public class XTAdapter extends AdapterBase {
	
	protected String getImplClassName() {
		return "com.jclark.xsl.trax.TransformerFactoryImpl";
	}
	
	protected void setVerboseListener(TransformerFactory factory, TraceListenerImpl tracer) {
		//factory.setAttribute(net.sf.saxon.FeatureKeys.TRACE_LISTENER, tracer);
	}
	
}
