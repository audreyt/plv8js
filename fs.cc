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

#ifndef _SRC_THREADS_JS_FS_CC_
#define _SRC_THREADS_JS_FS_CC_

#include <v8.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <dlfcn.h>
#include "./js_common.cc"


namespace js {

static Handle<v8::Value> realpathSync_(const Arguments &args) {
	HandleScope scope;

	String::Utf8Value v(Handle<String>::Cast(args[0]));
	char buf[PATH_MAX];
	if (realpath(*v, buf) == NULL) {
		sprintf(buf, "Error: realpath:%s %s\n", *v, strerror(errno));
		return ThrowException(Exception::Error(String::New(buf)));
	}

	return scope.Close(String::New(buf));
}

static Handle<v8::Value> readFileSync_(const Arguments &args) {
	HandleScope scope;

	FILE *f = fopen(*String::Utf8Value(Handle<String>::Cast(args[0])), "r");
	if (f == NULL) {
		char str[56];
		sprintf(str, "Error: readfile open failed. %d %s\n", errno, strerror(errno));
		return ThrowException(Exception::Error(String::New(str)));
	}
	fseek(f, 0, SEEK_END);
	size_t s = ftell(f);
	rewind(f);

	char *buf = (char*)malloc((s+1)*sizeof(char));
	size_t r = fread(buf, sizeof(char), s, f);
	if (r < s) {
		char str[56];
		sprintf(str, "Error: readfile read failed. %d %s\n", ferror(f), strerror(ferror(f)));
		delete[] buf;
		fclose(f);
		ThrowException(Exception::Error(String::New(str)));
	}
	buf[s] = 0;
	Handle<String> str = String::New(buf);
	free(buf);
	fclose(f);

	return scope.Close(str);
}

static Handle<v8::Value> getcwd_(const Arguments &args) {
	HandleScope scope;

	char buf[PATH_MAX];
	if (getcwd(buf, PATH_MAX) != NULL) {
		return scope.Close(String::New(buf));
	} else {
		sprintf(buf, "Get current directory failed. Error: %s\n", strerror(errno));
		ThrowException(Exception::Error(String::New(buf)));
	}

	return scope.Close(Undefined());
}

static Handle<v8::Value> chdir_(const Arguments &args) {
	HandleScope scope;

	if (chdir(*String::Utf8Value(Handle<String>::Cast(args[0]))) == 0) {
		return scope.Close(True());
	}
	//fprintf(stderr, "Error: chdir:%d %s\n", errno, strerror(errno));
	return scope.Close(False());
}

static Handle<v8::Value> loadso(const Arguments &args) {
	HandleScope scope;

	void *handle;
	//void init(Handle<Object> target)
	void (*module_init_fn)(Handle<Object>);
	char *error;

	handle = dlopen(*String::Utf8Value(Handle<String>::Cast(args[0])), RTLD_LAZY);
	if (!handle) {
		fprintf(stderr, "Error: load so failed. %s\n", dlerror());
		exit(EXIT_FAILURE);
	}

	dlerror();	//clear any existing error

	// form man page: POSIZ.1-2003
	/* Writing: cosine = (double (*)(double)) dlsym(handle, "cos");
	 would seem more natural, but the C99 standard leaves
	 casting from "void *" to a function pointer undefined.
	 The assignment used below is the POSIX.1-2003 (Technical
	 Corrigendum 1) workaround; see the Rationale for the
	 POSIX specification of dlsym(). */
	//double (*cosine)(double);
	//*(void **) (&cosine) = dlsym(handle, "cos");

	*(void **) (&module_init_fn) = dlsym(handle, "init");

	if ((error=dlerror()) != NULL ) {
		fprintf(stderr, "Error: load so 'init' function failed. %s\n", error);
		exit(EXIT_FAILURE);
	}

	(*module_init_fn)(Handle<Object>::Cast(args[1]));

	//dlclose(handle);


	return scope.Close(Undefined());
}

static Handle<v8::Value> existsSync_(const Arguments &args) {
	HandleScope scope;

	struct stat sts;
	if ((stat(*String::Utf8Value(Handle<String>::Cast(args[0])), &sts)) == -1 && errno == ENOENT) {
		return scope.Close(False());
	}
	return scope.Close(True());
}

static Handle<v8::Value> statSync_(const Arguments &args) {
	HandleScope scope;

	struct stat sts;
	if ((stat(*String::Utf8Value(Handle<String>::Cast(args[0])), &sts)) == -1 && errno == ENOENT) {
		return scope.Close(False());
	}
	Local<Object> obj = Object::New();
	obj->Set(String::NewSymbol("dev"), Integer::New(sts.st_dev));
	obj->Set(String::NewSymbol("ino"), Integer::New(sts.st_ino));
	obj->Set(String::NewSymbol("mode"), Integer::New(sts.st_mode));
	obj->Set(String::NewSymbol("nlink"), Integer::New(sts.st_nlink));
	obj->Set(String::NewSymbol("uid"), Integer::New(sts.st_uid));
	obj->Set(String::NewSymbol("gid"), Integer::New(sts.st_gid));
	obj->Set(String::NewSymbol("rdev"), Integer::New(sts.st_rdev));
	obj->Set(String::NewSymbol("size"), Integer::New(sts.st_size));
	obj->Set(String::NewSymbol("blksize"), Integer::New(sts.st_blksize));
	obj->Set(String::NewSymbol("blocks"), Integer::New(sts.st_blocks));
	obj->Set(String::NewSymbol("atime"), Date::New(sts.st_atime));
	obj->Set(String::NewSymbol("mtime"), Date::New(sts.st_mtime));
	obj->Set(String::NewSymbol("ctime"), Date::New(sts.st_ctime));
	obj->Set(String::NewSymbol("isFile"), Boolean::New(S_ISREG(sts.st_mode)));
	obj->Set(String::NewSymbol("isDirectory"), Boolean::New(S_ISDIR(sts.st_mode)));
	obj->Set(String::NewSymbol("isCharacterDevice"), Boolean::New(S_ISCHR(sts.st_mode)));
	obj->Set(String::NewSymbol("isBlockDevice"), Boolean::New(S_ISBLK(sts.st_mode)));
	obj->Set(String::NewSymbol("isFIFO"), Boolean::New(S_ISFIFO(sts.st_mode)));
	obj->Set(String::NewSymbol("isSymbolicLink"), Boolean::New(S_ISLNK(sts.st_mode)));
	obj->Set(String::NewSymbol("isSocket"), Boolean::New(S_ISSOCK(sts.st_mode)));

	return scope.Close(obj);
}

static Handle<v8::Value> readSync_(const Arguments &args) {

	return Undefined();
}


static Handle<Object> install_native_fs(Handle<Object>& global) {
	HandleScope scope;

	// function type setup: not for console, console is object type
//	Handle<FunctionTemplate> ft = FunctionTemplate::New();
//	Handle<ObjectTemplate> ot = ft->InstanceTemplate();
//	ot->SetInternalFieldCount(1);
//	Handle<ObjectTemplate> proto_t = ft->PrototypeTemplate();
//	proto_t->Set("log", FunctionTemplate::New(console_log));
//	proto_t->Set("error", FunctionTemplate::New(console_error));
//	ft->SetClassName(String::New("console"));
//	global->Set("Name", ft->GetFunction());


	//object type setup
	Handle<Object> obj = Object::New();
	JSObjFn(obj, "realpathSync", realpathSync_);
	JSObjFn(obj, "readFileSync", readFileSync_);
	JSObjFn(obj, "getcwd", getcwd_);
	JSObjFn(obj, "chdir", chdir_);
	JSObjFn(obj, "existsSync", existsSync_);
	JSObjFn(obj, "statSync", statSync_);
	//obj->Set(String::New("readFileSync"), FunctionTemplate::New(readFileSync)->GetFunction());
	global->Set(String::New("native_fs_"), obj);
	return global;
}


}

#endif
