//
//  AdapterBase.java
//  XSLPalette
//
//  Created by Todd Ditchendorf on 11/25/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

import java.util.*;
import java.io.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;

import org.apache.xalan.*;
import org.apache.xalan.transformer.*;
import org.apache.xalan.trace.*;

public abstract class AdapterBase {
	
	protected abstract String getImplClassName();
	protected abstract void setVerboseListener(TransformerFactory factory, TraceListenerImpl tracer);
	
	public AdapterBase() {
		System.setProperty("javax.xml.transform.TransformerFactory", getImplClassName());
	}	
		
	public String transform(String[] args) {
		List list = Arrays.asList(args);
		list = list.subList(1, list.size());
		return doTransform(list);
	}
	
	protected String doTransform(List args) {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		PrintStream ps = new PrintStream(out);
		
		try {
			
			String sourceURLString = (String)args.get(0);
			String styleURLString  = (String)args.get(1);
			boolean verbose = Boolean.parseBoolean((String)args.get(2));
			
			TransformerFactory factory = TransformerFactory.newInstance();

			TraceListenerImpl tracer = new TraceListenerImpl();
			if (verbose) {
				setVerboseListener(factory, tracer);
			}
			factory.setErrorListener(tracer);
			
			try {
				Transformer transformer = factory.newTransformer(new StreamSource(styleURLString));
				transformer.setErrorListener(tracer);
				
				if (verbose && transformer instanceof org.apache.xalan.transformer.TransformerImpl) {
					TransformerImpl transformerImpl = (TransformerImpl)transformer;
					TraceManager trMgr = transformerImpl.getTraceManager();
					trMgr.addTraceListener(tracer);
				}
				
				for (int i = 3; i < args.size(); i++) {
					transformer.setParameter((String)args.get(i), (String)args.get(++i));
				}
				transformer.transform(new StreamSource(sourceURLString), new StreamResult(ps));
			} catch (Exception e) {
				System.err.println("here we are");
				e.printStackTrace();
				System.err.println(e.getMessage());
				tracer.sendError(e.getMessage());
			}
			
		} catch (Throwable t) {
			ps.println("Unknown Java Error!: " + t.getMessage());
			System.err.println(t.getMessage());
		}
		return out.toString();
	}
	
}
