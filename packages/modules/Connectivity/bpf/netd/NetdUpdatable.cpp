/*
 * Copyright (C) 2022 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "NetdUpdatable"

#include "BpfHandler.h"

#include <fcntl.h>
#include <string>
#include <unistd.h>

#include <android-base/logging.h>
#include <android-base/result.h>

#include "NetdUpdatablePublic.h"

static android::net::BpfHandler sBpfHandler;

static void logInitFailureToKmsg(const std::string& msg) {
    int fd = open("/dev/kmsg", O_WRONLY | O_CLOEXEC);
    if (fd < 0) return;
    std::string line = "NetdUpdatable: init failed: " + msg + "\n";
    write(fd, line.data(), line.size());
    close(fd);
}

int libnetd_updatable_init(const char* cg2_path) {
    android::base::InitLogging(/*argv=*/nullptr);
    LOG(INFO) << __func__ << ": Initializing";

    android::base::Result<void> ret = sBpfHandler.init(cg2_path);
    if (!ret.ok()) {
        LOG(ERROR) << __func__ << ": Failed: " << ret.error().message();
        logInitFailureToKmsg(ret.error().message());
        // AOSP aborts here, but this device runs a 4.9 kernel that cannot provide
        // everything a 26Q2 platform expects. Keep netd alive with degraded BPF.
        return 0;
    }
    return 0;
}

int libnetd_updatable_tagSocket(int sockFd, uint32_t tag, uid_t chargeUid, uid_t realUid) {
    return sBpfHandler.tagSocket(sockFd, tag, chargeUid, realUid);
}

int libnetd_updatable_untagSocket(int sockFd) {
    return sBpfHandler.untagSocket(sockFd);
}
