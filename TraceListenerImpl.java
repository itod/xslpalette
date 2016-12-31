//
//  TraceListenerImpl.java
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/20/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

import javax.xml.transform.*;

import com.icl.saxon.*;
import com.icl.saxon.trace.*;
import com.icl.saxon.om.*;

import net.sf.saxon.*;
import net.sf.saxon.trace.*;
import net.sf.saxon.om.*;
import net.sf.saxon.expr.*;
import net.sf.saxon.style.*;

import org.apache.xalan.*;
import org.apache.xalan.trace.*;

public class TraceListenerImpl implements com.icl.saxon.trace.TraceListener,
	net.sf.saxon.trace.TraceListener, org.apache.xalan.trace.TraceListener, javax.xml.transform.ErrorListener 
{
	
	static {
		//System.loadLibrary("XPaletteJNILib");
	}
		
	public native void doSendMessage(String msg);
	
	public native void soSendError(String msg);
	
	public void sendMessage(String msg) {
		doSendMessage(msg + "\n\n");
	}
	
	public void sendError(String msg) {
		doSendMessage(msg + "\n\n");
	}
		
	// ErrorListener
	public void error(TransformerException e) {
		sendMessage("Error: " + e.getMessage() + "\n\n");
	}
	
	public void fatalError(TransformerException e) {
		sendMessage("Fatal Error: " + e.getMessage());
	}
	
	public void warning(TransformerException e) {
		sendMessage("Warning: " + e.getMessage());
	}
	
		
	static String[] nodeTypes6_5 = new String[com.icl.saxon.om.NodeInfo.NUMBER_OF_TYPES+1];
	static {
		nodeTypes6_5[com.icl.saxon.om.NodeInfo.ATTRIBUTE] = "Attribute";
		nodeTypes6_5[com.icl.saxon.om.NodeInfo.COMMENT] = "Comment";
		nodeTypes6_5[com.icl.saxon.om.NodeInfo.ELEMENT] = "Element";
		nodeTypes6_5[com.icl.saxon.om.NodeInfo.NAMESPACE] = "Namespace";
		nodeTypes6_5[com.icl.saxon.om.NodeInfo.NODE] = "Node";
		nodeTypes6_5[com.icl.saxon.om.NodeInfo.PI] = "Processing Instruction";
		nodeTypes6_5[com.icl.saxon.om.NodeInfo.ROOT] = "Root";
		nodeTypes6_5[com.icl.saxon.om.NodeInfo.TEXT] = "Text";
	}
	
	private String getNodeTrace(com.icl.saxon.om.NodeInfo element, boolean showStringValue) {
		String stringValue = null;
		
		if (showStringValue) {
			stringValue = element.getStringValue();
			if (null == stringValue) {
				stringValue = "";
			} else if (stringValue.length() > 12) {
				stringValue = stringValue.substring(0, 11) + "...";
			}
		}
		
		StringBuffer buff = new StringBuffer();
		buff.append("\n\t\tline: ").append(element.getLineNumber())
			.append("\n\t\ttype: ").append(nodeTypes6_5[element.getNodeType()])
			.append("\n\t\tuniversal name: {").append(element.getURI()).append("}").append(element.getLocalName())
			.append("\n\t\tlexical qname: ").append(element.getPrefix()).append(":").append(element.getLocalName());
		
		if (showStringValue) {
			buff.append("\n\t\tstring-value: ").append(stringValue);
		}
		buff.append("\n\t\tbase URI: ").append(element.getBaseURI());
		buff.append("\n\t\tsystem ID: ").append(element.getSystemId());

		return buff.toString();
	}
	
	// com.icl.saxon.trace.TraceListener
	public void close() {
		sendMessage("Transformation complete.");
	}
	
	public void open() {
		sendMessage("Begin Transformation");
	}
	
	public void enter(com.icl.saxon.om.NodeInfo element, com.icl.saxon.Context context) {
		sendMessage("\tBegin Node" + getNodeTrace(element, true));
	}
	
	public void enterSource(com.icl.saxon.NodeHandler handler, com.icl.saxon.Context context) {
		sendMessage("Begin Source");
	}
	
	public void leave(com.icl.saxon.om.NodeInfo element, com.icl.saxon.Context context) {
		sendMessage("\tEnd Node" + getNodeTrace(element, false));
	}
	
	public void leaveSource(com.icl.saxon.NodeHandler handler, com.icl.saxon.Context context) {
		sendMessage("End Source");
	}
	
	public void toplevel(com.icl.saxon.om.NodeInfo element) {
		sendMessage("\tTop Level Element" + getNodeTrace(element, false));
	}
	
	
	private String getInstructionTrace(InstructionInfo instruction, boolean showStringValue) {
		
		String stringValue = null;
		/*
		if (showStringValue) {
			stringValue = element.getStringValue();
			if (null == stringValue) {
				stringValue = "";
			} else if (stringValue.length() > 12) {
				stringValue = stringValue.substring(0, 11) + "...";
			}
		}
		*/
		StringBuffer buff = new StringBuffer();
		buff.append("\n\t\tline: ").append(instruction.getLineNumber())
			//.append("\n\t\ttype: ").append(StandardNames.getDisplayName(instruction.getObjectNameCode()));
			//.append("\n\t\tlexical universal name: ").append(StandardNames.getClarkName(instruction.getConstructType()))
			.append("\n\t\tlexical qname: ").append(StandardNames.getDisplayName(instruction.getConstructType()))
			.append("\n\t\tobject name: ").append(StandardNames.getDisplayName(instruction.getObjectNameCode()));
		/*
		if (showStringValue) {
			buff.append("\n\t\tstring-value: ").append(stringValue);
		}
		 */
		//buff.append("\n\t\tbase URI: ").append(element.getBaseURI());
		//buff.append("\n\t\tsystem ID: ").append(element.getSystemId());
		
		return buff.toString();
	}
	
	
	
	// net.sf.saxon.trace.TraceListener
	public void endCurrentItem(Item currentItem) {
		//sendMessage("endCurrentItem");
	}
	
	public void enter(InstructionInfo instruction, XPathContext context) {
		//sendMessage("\tBegin instruction" +getInstructionTrace(instruction, false));
	}
	
	public void leave(InstructionInfo instruction) {
		//sendMessage("\tEnd instruction" +getInstructionTrace(instruction, false));
	}
	
	public void startCurrentItem(Item currentItem) {
		//sendMessage("startCurrentItem");
	}
	
	
	
	// org.apache.xalan.trace.TraceListener
	public void trace(org.apache.xalan.trace.TracerEvent evt) {
		//sendMessage("TracerEvent:\n"+TracerEvent.printNode(evt.m_sourceNode));
	}
	
    public void selected(org.apache.xalan.trace.SelectionEvent evt) throws javax.xml.transform.TransformerException {
		//sendMessage("SelectionEvent:\nXPath: "+evt.m_xpath+"\nNode: "+TracerEvent.printNode(evt.m_sourceNode));
	}
	
    public void generated(org.apache.xalan.trace.GenerateEvent evt) {
		
	}
	
}
