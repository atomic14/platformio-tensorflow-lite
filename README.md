# Extract tensorflow-lite for use in platform.io with the ESP32

There are a few blog posts on how to pull out tensorflow-lite for use with platform.io.

I've tried to minimise the amount of restructuring of the `tfmicro` folders in this repo by making using a `library.json` to setup include paths.

This should make it easier to update to newer versions of TensorflowLite at they become available.

To build the docker file run

```
docker build . -t tflite-generator
```

You can specify arguments for this - for example to use the `master` branch of TensorFlow do the following:

```
docker build . -t tflite-generator --build-arg tensorflow_version=master
```

And to specify the esp-idf version:

```
docker build . -t tflite-generator --build-arg tensorflow_version=master --build-arg esp_idf_version=release/v4.0
```

This can take a considerable amount of time as the stage where it downloads `https://www.cs.toronto.edu/~kriz/cifar-10-binary.tar.gz` can take a while. Got off and make a cup of tea.

Once the docker image has been built you can copy the code out of the image using:

```
docker run -v `pwd`/lib:/dst -t tflite-generator
```

This will copy the `tfmicro` source code for the ESP32 into a folder called `lib`.

Copy the contents of the lib folder into you project's lib folder.

Copy the `library.json` into the `tfmicro` folder in your lib folder.

Edit the file `lib/tfmicro/third_party/flatbuffers/include/flatbuffers/base.h`

And change lines 34 onwards to look like this:

```C
// #if defined(ARDUINO) && !defined(ARDUINOSTL_M_H)
//   #include <utility.h>
// #else
  #include <utility>
// #endif
```

For release 2.3 of TensorFlow you will need to edit the file `lib/tfmicro/tensorflow/lite/micro/micro_allocator.cc` and find the line that refers to `static_assert` add a message to the end of this to remove the compilation error or just comment out the block.

```C
      static_assert((std::is_same<kFlatBufferVectorType, int32_t>() &&
                     std::is_same<kTfLiteArrayType, TfLiteIntArray>()) ||
                    (std::is_same<kFlatBufferVectorType, float>() &&
                     std::is_same<kTfLiteArrayType, TfLiteFloatArray>()), "Error");
```

If you are using the `master` branch of TensorFlow then this is not needed as the code has changed substantially.

That should do it!
