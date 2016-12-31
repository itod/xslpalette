//
//  MyJavaClass.java
//  MyFirstJVMProject
//
//  Created by itod on 8/18/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//


public class CausewayBridgeMain {
	
	public static void main(String[] args) {
		//System.out.println("main from CausewayBridgeMain!!!!");
		//System.setProperty("java.library.path", System.getProperty("java.library.path"));
		//System.out.println("java.ext.dirs: " + System.getProperty("java.ext.dirs"));
		//System.out.println("java.class.path: " + System.getProperty("java.class.path"));
		
		//System.getProperties().list(System.out);		
		System.load(args[0]);
	}
	
	public CausewayBridgeMain() {
	}
	
	public String sayHello(String str) {
		System.out.println(str);
		return "Hello from Java!!!";
	}
	
}
