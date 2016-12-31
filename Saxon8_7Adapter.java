//
//  Saxon8_7Adapter.java
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/19/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

import java.util.*;
import java.io.*;
import java.net.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;
import net.sf.saxon.*;
import net.sf.saxon.query.*;
import net.sf.saxon.om.*;

public class Saxon8_7Adapter extends AdapterBase {

	protected String getImplClassName() {
		return "net.sf.saxon.TransformerFactoryImpl";
	}
	
	protected void setVerboseListener(TransformerFactory factory, TraceListenerImpl tracer) {
		factory.setAttribute(net.sf.saxon.FeatureKeys.TRACE_LISTENER, tracer);
	}
	
	public String transform(String[] args) {
		List list = Arrays.asList(args);
		String lang = (String)list.get(0);
		list = list.subList(1,list.size());
		
		if ("xslt".equalsIgnoreCase(lang))
			return doTransform(list);
		else 
			return doQuery(list);
	}
	
	private String doQuery(List args) {
		StringWriter out = new StringWriter();

		try {

			String sourceURLString = (String)args.get(0);
			String xqueryURLString  = (String)args.get(1);
			boolean verbose = Boolean.parseBoolean((String)args.get(2));
			
			Configuration config = new Configuration();
			StaticQueryContext staticCtxt = new StaticQueryContext(config);
			
			Reader reader = null;
			if (xqueryURLString.startsWith("http://")) {
				reader = new InputStreamReader(new URL(xqueryURLString).openStream());
			} else {
				reader = new FileReader(xqueryURLString);
			}
			
			XQueryExpression expr = staticCtxt.compileQuery(reader);
			
			DynamicQueryContext dynCtxt = new DynamicQueryContext(config);
			dynCtxt.setContextNode(staticCtxt.buildDocument(new StreamSource(sourceURLString)));

			for (int i = 3; i < args.size(); i++) {
				dynCtxt.setParameter((String)args.get(i), (String)args.get(++i));
			}
			
			Result result = new StreamResult(out);
			Properties props = new Properties();
			props.setProperty(OutputKeys.INDENT, "yes");
			
			boolean wrap = false;
			
			if (wrap) {
				SequenceIterator iter = expr.iterator(dynCtxt);
				DocumentInfo resultDoc = QueryResult.wrap(iter, config);
				QueryResult.serialize(resultDoc, result, props, config);
			} else {
				expr.run(dynCtxt, result, props);
			}

		} catch (Throwable t) {
			out.write("Unknown Java Error!: " + t.getMessage());
			System.err.println(t.getMessage());
		}
		
		return out.toString();
	}
	
}
