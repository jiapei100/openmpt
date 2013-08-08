/*
 * AudioReadTarget.h
 * -----------------
 * Purpose: Callback class implementations for audio data read via CSoundFile::Read.
 * Notes  : (currently none)
 * Authors: OpenMPT Devs
 * The OpenMPT source code is released under the BSD license. Read LICENSE for more details.
 */


#include "Sndfile.h"
#include "Dither.h"
#include "SampleFormatConverters.h"
#include "MixerLoops.h"


template<typename Tsample>
class AudioReadTargetBuffer
	: public IAudioReadTarget
{
private:
	std::size_t countRendered;
	Dither &dither;
protected:
	Tsample *outputBuffer;
	Tsample * const *outputBuffers;
public:
	AudioReadTargetBuffer(Dither &dither_, Tsample *buffer, Tsample * const *buffers)
		: countRendered(0)
		, dither(dither_)
		, outputBuffer(buffer)
		, outputBuffers(buffers)
	{
		ASSERT(SampleFormat(SampleFormatTraits<Tsample>::sampleFormat).IsValid());
	}
	virtual ~AudioReadTargetBuffer() { }
	std::size_t GetRenderedCount() const { return countRendered; }
public:
	virtual void DataCallback(int *MixSoundBuffer, std::size_t channels, std::size_t countChunk)
	{
		// Convert to output sample format and optionally perform dithering and clipping if needed

		const SampleFormat sampleFormat = SampleFormatTraits<Tsample>::sampleFormat;

		if(sampleFormat.IsInt())
		{
			dither.Process(MixSoundBuffer, countChunk, channels, sampleFormat.GetBitsPerSample());
		}

		if(outputBuffer)
		{
			ConvertInterleavedFixedPointToInterleaved<MIXING_FRACTIONAL_BITS>(outputBuffer + (channels * countRendered), MixSoundBuffer, channels, countChunk);
		}
		if(outputBuffers)
		{
			Tsample *buffers[4] = { nullptr, nullptr, nullptr, nullptr };
			for(std::size_t channel = 0; channel < channels; ++channel)
			{
				buffers[channel] = outputBuffers[channel] + countRendered;
			}
			ConvertInterleavedFixedPointToNonInterleaved<MIXING_FRACTIONAL_BITS>(buffers, MixSoundBuffer, channels, countChunk);
		}

		countRendered += countChunk;
	}
};


#ifndef MODPLUG_TRACKER

template<typename Tsample>
class AudioReadTargetGainBuffer
	: public AudioReadTargetBuffer<Tsample>
{
private:
	typedef AudioReadTargetBuffer<Tsample> Tbase;
private:
	const float gainFactor;
public:
	AudioReadTargetGainBuffer(Dither &dither, Tsample *buffer, Tsample * const *buffers, float gainFactor_)
		: Tbase(dither, buffer, buffers)
		, gainFactor(gainFactor_)
	{
		return;
	}
	virtual ~AudioReadTargetGainBuffer() { }
public:
	virtual void DataCallback(int *MixSoundBuffer, std::size_t channels, std::size_t countChunk)
	{
		const SampleFormat sampleFormat = SampleFormatTraits<Tsample>::sampleFormat;
		const std::size_t countRendered = Tbase::GetRenderedCount();

		if(sampleFormat.IsInt())
		{
			// Apply final output gain for non floating point output
			ApplyGain(MixSoundBuffer, channels, countChunk, Util::Round<int32>(gainFactor * (1<<16)));
		}

		Tbase::DataCallback(MixSoundBuffer, channels, countChunk);

		if(sampleFormat.IsFloat())
		{
			// Apply final output gain for floating point output after conversion so we do not suffer underflow or clipping
			ApplyGain(reinterpret_cast<float*>(Tbase::outputBuffer), reinterpret_cast<float*const*>(Tbase::outputBuffers), countRendered, channels, countChunk, gainFactor);
		}

	}
};

#endif // !MODPLUG_TRACKER
