import { NativeModules, Platform } from 'react-native'

const RNAudioSession = NativeModules.RNAudioSession
const IS_IOS = Platform.OS === 'ios'

export const AudioCategories = {
	Ambient: 'Ambient',
	SoloAmbient: 'SoloAmbient',
	Playback: 'Playback',
	Record: 'Record',
	PlayAndRecord: 'PlayAndRecord',
	MultiRoute: 'MultiRoute'
}

export const AudioOptions = {
	MixWithOthers: 'MixWithOthers',
	DuckOthers: 'DuckOthers',
	InterruptSpokenAudioAndMixWithOthers: 'InterruptSpokenAudioAndMixWithOthers',
	AllowBluetooth: 'AllowBluetooth',
	AllowBluetoothA2DP: 'AllowBluetoothA2DP',
	AllowAirPlay: 'AllowAirPlay',
	DefaultToSpeaker: 'DefaultToSpeaker'
}

export const AudioModes = {
	Default: 'Default',
	VoiceChat: 'VoiceChat',
	VideoChat: 'VideoChat',
	GameChat: 'GameChat',
	VideoRecording: 'VideoRecording',
	Measurement: 'Measurement',
	MoviePlayback: 'MoviePlayback',
	SpokenAudio: 'SpokenAudio'
}

export const AudioPortOverrides = {
	None: 'None',
	Speaker: 'Speaker'
}

export const AudioRecordPermissions = {
	Granted: 'Granted',
	Denied: 'Denied',
	Undetermined: 'Undetermined'
}

export const AudioRouteSharingPolicies = {
	Default: 'Default',
	Independent: 'Independent'
}

const create = () => {

	const noAndroid = () => {
		return new Promise((resolve, reject) => {
			resolve("Not supported on Android.")
		})
	}

	const noIos = () => {
		return new Promise((resolve, reject) => {
			resolve("AudioSession is not supported on IOS.")
		})
	}

	/*
	 *
	 * Audio session configuration
	 *
	 */

	const currentCategory = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.category(event => {
					resolve(event)
				})
			})
		} else {
			return noAndroid()
		}
	}

	const currentOptions = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.options().then((event) => {
					resolve(event)
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const currentMode = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.mode(event => {
					resolve(event)
				})
			})
		} else {
			return noAndroid()
		}
	}

	const availableCategories = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.availableCategories().then(event => {
					resolve(event)
				})
			})
		} else {
			return noAndroid()
		}
	}

	const availableModes = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.availableModes().then(event => {
					resolve(event)
				})
			})
		} else {
			return noAndroid()
		}
	}

	const setActive = active => {
		if (IS_IOS) {
			return RNAudioSession.setActive(active)
		} else {
			return noAndroid()
		}
	}

	const setCategory = (category, options) => {
		if (IS_IOS) {
			return RNAudioSession.setCategory(category, options)
		} else {
			return noAndroid()
		}
	}

	const setMode = mode => {
		if (IS_IOS) {
			return RNAudioSession.setMode(mode)
		} else {
			return noAndroid()
		}
	}

	const setCategoryAndMode = (category, mode, options) => {
		if (IS_IOS) {
			return RNAudioSession.setCategoryAndMode(category, mode, options)
		} else {
			return noAndroid()
		}
	}

	const init = () => {
		return RNAudioSession.init();
	}

	const currentRoute = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.currentRoute().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}


	/*
	 *
	 * Responding to other audio
	 *
	 */

	const otherAudioPlaying = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.otherAudioPlaying().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const secondaryAudioShouldBeSilencedHint = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.secondaryAudioShouldBeSilencedHint().then((event) => {
					resolve(event)
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}


	/*
	 *
	 * Recording permissions
	 *
	 */

	const recordPermission = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.recordPermission().then((event) => {
					resolve(event)
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const requestRecordPermission = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.requestRecordPermission().then((event) => {
					resolve(event)
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}


	/*
	 *
	 * Audio routes
	 *
	 */

	const inputAvailable = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.inputAvailable().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const availableInputs = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.availableInputs().then((event) => {
					resolve(event)
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const preferredInput = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.preferredInput().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const setPreferredInput = (uid) => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.setPreferredInput(uid).then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const inputDataSources = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.inputDataSources().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const inputDataSource = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.inputDataSource().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}


	const setInputDataSource = (dataSourceId) => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.inputDataSource(dataSourceId).then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const outputDataSources = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.outputDataSources().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const outputDataSource = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.outputDataSource().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const setOutputDataSource = (dataSourceId) => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.setOutputDataSource(dataSourceId).then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const overrideOutputAudioPort = (port) => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.overrideOutputAudioPort(port).then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}


	const routeSharingPolicy = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.routeSharingPolicy().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const setCategoryAndModeAndRouteSharingPolicy = (category, mode, routeSharingPolicy, options) => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.setCategoryAndModeAndRouteSharingPolicy(category, mode, routeSharingPolicy, options).then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}



	/*
	 *
	 * Audio channels
	 *
	 */

	const inputNumberOfChannels = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.inputNumberOfChannels().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const maximumInputNumberOfChannels = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.maximumInputNumberOfChannels().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const preferredInputNumberOfChannels = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.preferredInputNumberOfChannels().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const setPreferredInputNumberOfChannels = (numChannels) => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.setPreferredInputNumberOfChannels(numChannels).then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const outputNumberOfChannels = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.outputNumberOfChannels().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const maximumOutputNumberOfChannels = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.maximumOutputNumberOfChannels().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const preferredOutputNumberOfChannels = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.preferredOutputNumberOfChannels().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const setPreferredOutputNumberOfChannels = (numChannels) => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.setPreferredOutputNumberOfChannels(numChannels).then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	/*
	 *
	 * Audio device settings
	 *
	 */

	const inputGain = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.inputGain().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const inputGainSettable = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.inputGainSettable().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const setInputGain = (inputGain) => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.setInputGain(inputGain).then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const outputVolume = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.outputVolume().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const inputLatency = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.inputLatency().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const outputLatency = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.outputLatency().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const sampleRate = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.sampleRate().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const preferredSampleRate = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.preferredSampleRate().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}


	const setPreferredSampleRate = (sampleRate) => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.setPreferredSampleRate(sampleRate).then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}


	const IOBufferDuration = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.IOBufferDuration().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const preferredIOBufferDuration = () => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.preferredIOBufferDuration().then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}


	const setPreferredIOBufferDuration = (duration) => {
		if (IS_IOS) {
			return new Promise((resolve, reject) => {
				RNAudioSession.setPreferredIOBufferDuration(duration).then((event) => {
					resolve(event);
				}).catch((err) => {
					reject(err);
				})
			})
		} else {
			return noAndroid()
		}
	}

	const resetAudio = () => {
		if (IS_IOS) {
			return noIos();
		} else {
			return new Promise((resolve, reject) => {
				RNAudioSession.resetAudio().then(() => {
					resolve({});
				}).catch((err) => {
					reject(err);
				})
			})
		}
	}


	return {
		init,
		currentCategory,
		currentOptions,
		currentMode,
		availableCategories,
		availableModes,
		setActive,
		setCategory,
		setMode,
		setCategoryAndMode,
		currentRoute,
		otherAudioPlaying,
		secondaryAudioShouldBeSilencedHint,
		recordPermission,
		requestRecordPermission,
		inputAvailable,
		preferredInput,
		setPreferredInput,
		availableInputs,
		inputDataSources,
		inputDataSource,
		setInputDataSource,
		outputDataSources,
		outputDataSource,
		setOutputDataSource,
		overrideOutputAudioPort,
		routeSharingPolicy,
		setCategoryAndModeAndRouteSharingPolicy,
		inputNumberOfChannels,
		maximumInputNumberOfChannels,
		preferredInputNumberOfChannels,
		setPreferredInputNumberOfChannels,
		outputNumberOfChannels,
		maximumOutputNumberOfChannels,
		preferredOutputNumberOfChannels,
		setPreferredOutputNumberOfChannels,
		inputGain,
		inputGainSettable,
		setInputGain,
		outputVolume,
		inputLatency,
		outputLatency,
		sampleRate,
		preferredSampleRate,
		setPreferredSampleRate,
		IOBufferDuration,
		preferredIOBufferDuration,
		setPreferredIOBufferDuration
	}
}

export default create()
