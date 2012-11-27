// Copyright(C) 2012 by RobertL
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

#ifndef _SRC_THREADS_JS_COMMON_CC_
#define _SRC_THREADS_JS_COMMON_CC_

#include <v8.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

using namespace v8;
namespace js {

static const PropertyAttribute attribute_ro_dd = (PropertyAttribute)(ReadOnly | DontDelete);
static const PropertyAttribute attribute_ro_de_dd = (PropertyAttribute)(ReadOnly | DontEnum | DontDelete);


#define JSObjFn(obj, name, fnname) \
	obj->Set(String::New(name), FunctionTemplate::New(fnname)->GetFunction(), js::attribute_ro_dd);

#define JSSYM(n) \
	String::NewSymbol(n)

#define JSFT(fn) \
	FunctionTemplate::New(fn)

#define JSFTGF(fn) \
	FunctionTemplate::New(fn)->GetFunction()

#define JSGETGLOBAL \
	Context::GetCurrent()->Global()

#define JSPerFn \
	Persistent<Function>

#define JSGETFN JSGETFN_CAST
#define JSGETFN_AS(obj, name) \
	 obj->Get(name).As<Function>();
#define JSGETFN_CAST(obj, name) \
	 Handle<Function>::Cast(obj->Get(name));


// common V8 macro section
#define JSErrorif(var, num, msg) \
	if (var == num) return ThrowException(Exception::Error(String::New(msg)));
#define JSObjGetInt32(obj, key) \
	obj->Get(String::NewSymbol(key))->Int32Value()
#define JSObjGetUint32(obj, key) \
	obj->Get(String::NewSymbol(key))->Uint32Value()
#define JSObjGetInt32Sym(obj, sym) \
	obj->Get(sym)->Int32Value()
#define JSObjGetString(obj, key) \
	Handle<String>::Cast(obj->Get(String::NewSymbol(key)))
#define JSObjGetStringSym(obj, sym) \
	Handle<String>::Cast(obj->Get(sym))
#define JSPropToFn(obj, fn, prop) \
	Handle<Function> fn = JSGETFN(obj, JSSYM(prop));
#define JSLoopProp(obj) \
	do { 																			\
		Local<Array> prop = obj->GetPropertyNames(); 								\
		for (int i=0, n=prop->Length(); i<n; ++i) {									\
			printf("%s\n", *(String::Utf8Value(Handle<String>::Cast(prop-Get(i)))));\
		} 																			\
	} while(0)

#define JS_GETHV_U32(obj, name) \
	obj->GetHiddenValue(JSSYM(#name))->Uint32Value();
#define JS_GETHV_ARRAY(obj, name) \
	Handle<Array>::Cast(obj->GetHiddenValue(JSSYM(#name)));

#define JS_GETGLOBALHV_U32(name) \
	JS_GETHV_U32(Context::GetCurrent()->Global(), name);
#define JS_GETGLOBALHV_ARRAY(name) \
	JS_GETHV_ARRAY(Context::GetCurrent()->Global(), name);


Handle<v8::Value> ThrowError(const char* msg) {
  return ThrowException(Exception::Error(String::New(msg)));
}
Handle<v8::Value> ThrowTypeError(const char* msg) {
  return ThrowException(Exception::TypeError(String::New(msg)));
}
Handle<v8::Value> ThrowRangeError(const char* msg) {
  return ThrowException(Exception::RangeError(String::New(msg)));
}


static void ReportException(TryCatch* try_catch) {
	HandleScope scope;

	String::Utf8Value exception(try_catch->Exception());
	Handle<Message> message = try_catch->Message();

	if (message.IsEmpty()) {
		printf("%s\n", *exception);

	} else {
		// Print (filename):(line number): (message).
		String::Utf8Value filename(message->GetScriptResourceName());
		int linenum = message->GetLineNumber();
		printf("%s:%i: %s\n", *filename, linenum, *exception);

		String::Utf8Value sourceline(message->GetSourceLine());
		char *tmpbuf = *sourceline;
		for (int i=0, n=sourceline.length(); i<n; ++i) {
			if (tmpbuf[i] == '\t') {
				putchar(' ');
			} else {
				putchar(tmpbuf[i]);
			}
		}
		putchar('\n');


		int start = message->GetStartColumn();
		for (int i = 0; i < start; i++) {
			putchar(' ');
		}
		int end = message->GetEndColumn();
		for (int i = start; i < end; i++) {
			putchar('^');
		}
		putchar('\n');

		String::Utf8Value stack_trace(try_catch->StackTrace());
		if (stack_trace.length() > 0) {
			printf("%s\n", *stack_trace);
		}
	}
}

}

#endif
