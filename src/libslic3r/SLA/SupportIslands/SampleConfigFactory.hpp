#ifndef slic3r_SLA_SuppotstIslands_SampleConfigFactory_hpp_
#define slic3r_SLA_SuppotstIslands_SampleConfigFactory_hpp_

#include <optional>
#include "SampleConfig.hpp"
#include "libslic3r/PrintConfig.hpp"

namespace Slic3r::sla {

/// <summary>
/// Factory to create configuration
/// </summary>
class SampleConfigFactory
{
public:
    SampleConfigFactory() = delete;

    static bool verify(SampleConfig &cfg);
    static SampleConfig create(float support_head_diameter_in_mm);

private:
    // TODO: REMOVE IT. Do not use in production
    // Global variable to temporary set configuration from GUI into SLA print steps
    static std::optional<SampleConfig> gui_sample_config_opt;
public:
    static SampleConfig &get_sample_config();
};
} // namespace Slic3r::sla
#endif // slic3r_SLA_SuppotstIslands_SampleConfigFactory_hpp_
