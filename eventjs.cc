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

#ifndef _SRC_EVENTJS_CC_
#define _SRC_EVENTJS_CC_

#include <v8.h>
#include "js_common.cc"

using namespace v8;
using namespace std;

namespace js {

//#define EVENTJS_USE_HANDLE_SCOPE

//#define EVENTJS_USE_EVENT_ONCE_FUNCTION
static Handle<v8::Value> eventjs_on_(const Arguments &args);
static Handle<v8::Value> eventjs_set_(const Arguments &args);
static Handle<v8::Value> eventjs_getlistener_(const Arguments &args);
static Handle<v8::Value> eventjs_emit_(const Arguments &args);
static Handle<v8::Value> eventjs_remove_all_listeners_(const Arguments &args);
static Handle<v8::Value> eventjs_clean_all_listeners_(const Arguments &args);
static Handle<v8::Value> eventjs_remove_listener_(const Arguments &args);
#ifdef EVENTJS_USE_EVENT_ONCE_FUNCTION
static Handle<v8::Value> eventjs_once_(const Arguments &args);
#endif

#ifdef EVENTJS_USE_HANDLE_SCOPE
#define EVENTJS_RETURN(h) return scope.Close(h);
#else
#define EVENTJS_RETURN(h) return h;
#endif

//#define EVENTJS_EMIT_CHECKIFHASFIRST


static Handle<v8::Value> eventjs_new_(const Arguments &args) {
#ifdef EVENTJS_USE_HANDLE_SCOPE
	HandleScope scope;
#endif

	if (!args.IsConstructCall()) {
		return js::ThrowTypeError("Event construct failed.(called as function, use'new'.)");
	}

	Handle<Object> self = args.This();
	self->Set(String::New("on_"), Object::New(), attribute_ro_dd);

	EVENTJS_RETURN(self);
}

static Handle<FunctionTemplate> eventjs_() {
//
//	Handle<Object> global = Context::GetCurrent()->Global();
//	Handle<String> event_ft_str = String::New("__EVENT_FT__");
//	if (global->Has(event_ft_str)) {
//		Handle<v8::Value> val = global->Get(event_ft_str);
//		return val;
//	}

	Persistent<FunctionTemplate> ft = Persistent<FunctionTemplate>::New(JSFT(eventjs_new_));
	//ft->Set("function_property", Number::New(1));
	ft->SetClassName(String::New("eventjs"));

	Handle<Template> proto_t = ft->PrototypeTemplate();
	proto_t->Set(String::New("on"), JSFT(eventjs_on_), attribute_ro_dd);
#ifdef EVENTJS_USE_EVENT_ONCE_FUNCTION
	proto_t->Set(String::New("once"), JSFT(eventjs_once_), attribute_ro_dd);
#endif
	proto_t->Set(String::New("set"), JSFT(eventjs_set_), attribute_ro_dd);
	proto_t->Set(String::New("getListener"), JSFT(eventjs_getlistener_), attribute_ro_dd);
	proto_t->Set(String::New("emit"), JSFT(eventjs_emit_), attribute_ro_dd);
	proto_t->Set(String::New("removeAllListener"), JSFT(eventjs_remove_all_listeners_), attribute_ro_dd);
	proto_t->Set(String::New("cleanAllListener"), JSFT(eventjs_clean_all_listeners_), attribute_ro_dd);
	proto_t->Set(String::New("removeListener"), JSFT(eventjs_remove_listener_), attribute_ro_dd);
	proto_t->Set(String::New("addListener"), JSFT(eventjs_on_), attribute_ro_dd);
	//proto->Set("proto_const", Number::New(2));

	// This did not work as what i want(will not add to new instance), need to set on_, once_ outside
	//Handle<ObjectTemplate> instance_t = ft->InstanceTemplate();
	//instance_t->Set(String::New("on_"), Object::New(), attribute_ro_dd);
#ifdef EVENTJS_USE_EVENT_ONCE_FUNCTION
	//instance_t->Set(String::New("once_"), Object::New(), attribute_ro_dd);
#endif

	return ft;
}


static Handle<v8::Value> eventjs_on_(const Arguments &args) {
#ifdef EVENTJS_USE_HANDLE_SCOPE
	HandleScope scope;
#endif
	Handle<Object> self = args.This();

	if (args[0]->IsString() && args[1]->IsFunction()) {
		Handle<String> event_name = Handle<String>::Cast(args[0]);

		Handle<Function> fn = Handle<Function>::Cast(args[1]);
		Handle<Object> cap = Handle<Object>::Cast(self->Get(JSSYM("on_")));

		if (cap->Has(event_name)) {
			Handle<v8::Value> val = cap->Get(event_name);
			if (val->IsFunction()) {
				Handle<Array> ar = Array::New();
				ar->Set(0, val);
				ar->Set(1, fn);
				cap->Set(event_name, ar);

			} else {
				Handle<Array> ar = Handle<Array>::Cast(val);
				ar->Set(ar->Length(), fn);
			}

		} else {
			cap->Set(event_name, fn);
		}
	}

	EVENTJS_RETURN(self);
}

static Handle<v8::Value> eventjs_set_(const Arguments &args) {
#ifdef EVENTJS_USE_HANDLE_SCOPE
	HandleScope scope;
#endif
	Handle<Object> self = args.This();

	if (args[0]->IsString() && args[1]->IsFunction()) {
		Handle<String> event_name = Handle<String>::Cast(args[0]);

		Handle<Function> fn = Handle<Function>::Cast(args[1]);
		Handle<Object> cap = Handle<Object>::Cast(self->Get(JSSYM("on_")));

		if (cap->Has(event_name)) {
			cap->Delete(event_name);
		}

		cap->Set(event_name, fn);
	}

	EVENTJS_RETURN(self);
}

static Handle<v8::Value> eventjs_getlistener_(const Arguments &args) {
#ifdef EVENTJS_USE_HANDLE_SCOPE
	HandleScope scope;
#endif
	Handle<Object> self = args.This();
	Handle<String> event_name = Handle<String>::Cast(args[0]);
	Handle<Object> cap = Handle<Object>::Cast(self->Get(JSSYM("on_")));
	Handle<Array> ar;
	Handle<Function> fn;
	int i, n;
	if (cap->Has(event_name)) {
		Handle<v8::Value> val = cap->Get(event_name);
		if (val->IsFunction()) {
			fn = Handle<Function>::Cast(val);
			EVENTJS_RETURN(fn);
		} else {
			ar = Handle<Array>::Cast(val);
			EVENTJS_RETURN(ar);
		}
	}
	EVENTJS_RETURN(Undefined());
}

static Handle<v8::Value> eventjs_emit_(const Arguments &args) {
#ifdef EVENTJS_USE_HANDLE_SCOPE
	HandleScope scope;
#endif
	Handle<Object> self = args.This();
	Handle<String> event_name = Handle<String>::Cast(args[0]);
	Handle<Object> cap = Handle<Object>::Cast(self->Get(JSSYM("on_")));
	Handle<v8::Value> argv[] = {args[1], args[2]};

#ifdef EVENTJS_EMIT_CHECKIFHASFIRST
	if (cap->Has(event_name)) {
#endif
		Handle<v8::Value> val = cap->Get(event_name);
		if (val->IsFunction()) {
			Handle<Function> fn = Handle<Function>::Cast(val);
			fn->Call(self, 2, argv);

			EVENTJS_RETURN(self);

		} else {
			int i, n;
			Handle<Array> ar = Handle<Array>::Cast(val);
			for (i=0, n=ar->Length(); i<n; ++i) {
				Handle<Function>::Cast(ar->Get(i))->Call(self, 2, argv);
			}

			EVENTJS_RETURN(self);
		}
#ifdef EVENTJS_EMIT_CHECKIFHASFIRST
	}
#endif

#ifdef EVENTJS_USE_EVENT_ONCE_FUNCTION
	cap = Handle<Object>::Cast(self->Get(JSSYM("once_")));
#ifdef EVENTJS_EMIT_CHECKIFHASFIRST
	if (cap->Has(event_name)) {
#endif
		Handle<v8::Value> val = cap->Get(event_name);
		if (val->IsFunction()) {
			Handle<Function> fn = Handle<Function>::Cast(val);
			fn->Call(self, 2, argv);

			EVENTJS_RETURN(self);

		} else {
			int i, n;
			Handle<Array> ar = Handle<Array>::Cast(val);
			for (i=0, n=ar->Length(); i<n; ++i) {
				Handle<Function>::Cast(ar->Get(i))->Call(self, 2, argv);
			}

			EVENTJS_RETURN(self);
		}
#ifdef EVENTJS_EMIT_CHECKIFHASFIRST
	}
#endif
#endif


	EVENTJS_RETURN(self);
}

#ifdef EVENTJS_USE_EVENT_ONCE_FUNCTION
static Handle<v8::Value> eventjs_once_(const Arguments &args) {
#ifdef EVENTJS_USE_HANDLE_SCOPE
	HandleScope scope;
#endif
	Handle<Object> self = args.This();

	if (args[0]->IsString() && args[1]->IsFunction()) {
		Handle<String> event_name = Handle<String>::Cast(args[0]);

		Handle<Function> fn = Handle<Function>::Cast(args[1]);
		Handle<Object> cap = Handle<Object>::Cast(self->Get(JSSYM("once_")));

		if (cap->Has(event_name)) {
			Handle<v8::Value> val = cap->Get(event_name);
			if (val->IsFunction()) {
				Handle<Array> ar = Array::New();
				ar->Set(0, val);
				ar->Set(1, fn);
				cap->Set(event_name, ar);

			} else {
				Handle<Array> ar = Handle<Array>::Cast(val);
				ar->Set(ar->Length(), fn);
			}

		} else {
			cap->Set(event_name, fn);
		}
	}

	EVENTJS_RETURN(self);
}
#endif


static Handle<v8::Value> eventjs_remove_all_listeners_(const Arguments &args) {
#ifdef EVENTJS_USE_HANDLE_SCOPE
	HandleScope scope;
#endif
	Handle<Object> self = args.This();
	Handle<Object> cap;

	if (args.Length() > 0) {
		Handle<String> event_name = Handle<String>::Cast(args[0]);
		cap = Handle<Object>::Cast(self->Get(JSSYM("on_")));
		if (cap->Has(event_name)) {
			cap->Delete(event_name);
		}
#ifdef EVENTJS_USE_EVENT_ONCE_FUNCTION
		cap = Handle<Object>::Cast(self->Get(JSSYM("once_")));
		if (cap->Has(event_name)) {
			cap->Delete(event_name);
		}
#endif

	} else {
		cap = Handle<Object>::Cast(self->Get(JSSYM("on_")));
		Local<Array> ar = cap->GetPropertyNames();
		for (int i=0, n=ar->Length(); i<n; ++i) {
			cap->Delete(Handle<String>::Cast(ar->Get(i)));
		}
#ifdef EVENTJS_USE_EVENT_ONCE_FUNCTION
		cap = Handle<Object>::Cast(self->Get(JSSYM("once_")));
		ar = cap->GetPropertyNames();
		for (int i=0, n=ar->Length(); i<n; ++i) {
			cap->Delete(Handle<String>::Cast(ar->Get(i)));
		}
#endif
	}


	EVENTJS_RETURN(self);
}

static Handle<v8::Value> eventjs_clean_all_listeners_(const Arguments &args) {
#ifdef EVENTJS_USE_HANDLE_SCOPE
	HandleScope scope;
#endif
	Handle<Object> self = args.This();
	Handle<Object> cap;

	cap = Handle<Object>::Cast(self->Get(JSSYM("on_")));
	Local<Array> ar = cap->GetPropertyNames();
	for (int i=0, n=ar->Length(); i<n; ++i) {
		cap->Delete(Handle<String>::Cast(ar->Get(i)));
	}
#ifdef EVENTJS_USE_EVENT_ONCE_FUNCTION
	cap = Handle<Object>::Cast(self->Get(JSSYM("once_")));
	ar = cap->GetPropertyNames();
	for (int i=0, n=ar->Length(); i<n; ++i) {
		cap->Delete(Handle<String>::Cast(ar->Get(i)));
	}
#endif


	EVENTJS_RETURN(self);
}

static Handle<v8::Value> eventjs_remove_listener_(const Arguments &args) {
#ifdef EVENTJS_USE_HANDLE_SCOPE
	HandleScope scope;
#endif
	Handle<Object> self = args.This();

	Handle<String> event_name = Handle<String>::Cast(args[0]);
	Handle<Function> fn = Handle<Function>::Cast(args[1]);

	int i, n;
	Handle<Object> cap;
	cap = Handle<Object>::Cast(self->Get(JSSYM("on_")));
	if (cap->Has(event_name)) {
		Handle<v8::Value> val = cap->Get(event_name);
		if (val->IsArray()) {
			Handle<Array> ar = Handle<Array>::Cast(cap->Get(event_name));
			for (i = 0, n = ar->Length(); i < n; ++i) {
				if (ar->Get(i) == fn) {
					for (n-=1; i < n; ++i) {
						ar->Set(i, ar->Get(i+1));
					}
					ar->Delete(i);
					break;
				}
			}

		} else {

			if (val == fn) {
				cap->Delete(event_name);
			}
		}
	}

#ifdef EVENTJS_USE_EVENT_ONCE_FUNCTION
	cap = Handle<Object>::Cast(self->Get(JSSYM("once_")));
	if (cap->Has(event_name)) {
		Handle<Array> ar = Handle<Array>::Cast(cap->Get(event_name));
		for (i = 0, n = ar->Length(); i < n; ++i) {
			if (ar->Get(i) == fn) {
				for (n-=1; i < n; ++i) {
					ar->Set(i, ar->Get(i+1));
				}
				ar->Delete(i);
				break;
			}
		}
	}
#endif


	EVENTJS_RETURN(self);

}
}

#endif
